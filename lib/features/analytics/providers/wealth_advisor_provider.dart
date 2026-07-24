import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/transaction.dart';
import '../../../models/category.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/category_localizer.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/presentation/categories_data.dart';
import '../../budgets/repositories/category_budget_repository.dart';
import '../../../models/category_budget.dart';
import '../models/advisor_nudge.dart';

/// Enum representing type of advice: Insight vs. Nudge
enum AdvisorType {
  insight,
  nudge,
}

/// State model for Wealth Advisor recommendations
class WealthAdvisorState {
  final String id;
  final String title;
  final String titleEn;
  final String titleRo;
  final String message;
  final IconData icon;
  final AdvisorType type;
  final NudgeSeverity severity;
  final String textEn;
  final String textRo;

  const WealthAdvisorState({
    required this.id,
    required this.title,
    String? titleEn,
    String? titleRo,
    required this.message,
    required this.icon,
    required this.type,
    this.severity = NudgeSeverity.info,
    String? textEn,
    String? textRo,
  })  : titleEn = titleEn ?? title,
        titleRo = titleRo ?? title,
        textEn = textEn ?? message,
        textRo = textRo ?? message;

  String getLocalizedTitle(String languageCode) {
    return languageCode == 'ro' ? titleRo : titleEn;
  }

  String getLocalizedText(String languageCode) {
    return languageCode == 'ro' ? textRo : textEn;
  }
}

/// Notifier to track dismissed advisor card IDs.
class DismissedNudgesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void dismiss(String id) {
    state = {...state, id};
  }

  void reset() {
    state = {};
  }
}

final dismissedNudgesProvider =
    NotifierProvider<DismissedNudgesNotifier, Set<String>>(() {
  return DismissedNudgesNotifier();
});

/// Riverpod provider computing current Wealth Advisor state based on transactions and budgets.
final wealthAdvisorProvider = Provider<WealthAdvisorState?>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final monthlyBudget = ref.watch(monthlyBudgetProvider).value ?? 1000.0;
  final dismissedIds = ref.watch(dismissedNudgesProvider);

  final transactions = transactionsAsync.value ?? <Transaction>[];
  if (transactions.isEmpty) return null;

  final List<WealthAdvisorState> candidates = [];

  // 1. Evaluate universal category budget thresholds (Warning at 80% usage, Alert at 100%, Safe at <50%)
  final categoryBudgets = ref.watch(categoryBudgetsStreamProvider).value ?? <CategoryBudget>[];
  final Map<String, double> customCategoryLimits = {
    for (final b in categoryBudgets) b.category: b.amountLimit,
  };

  final Map<String, double> categoryExpenses = {};
  for (final tx in transactions) {
    if (tx.amount < 0) {
      final catId = tx.categoryId ?? 'uncategorized';
      categoryExpenses[catId] = (categoryExpenses[catId] ?? 0.0) + tx.amount.abs();
    }
  }

  final double fallbackLimit = monthlyBudget > 0 ? (monthlyBudget / 3.0) : 300.0;

  categoryExpenses.forEach((catId, spentAmount) {
    final catObj = defaultCategories.firstWhere(
      (c) => c.id == catId,
      orElse: () => defaultCategories.first,
    );
    final categoryNameEn = CategoryLocalizer.getCategoryNameEn(catObj.name);
    final categoryNameRo = CategoryLocalizer.getCategoryNameRo(catObj.name);

    final double categoryBudgetLimit = customCategoryLimits[catObj.id] ??
        customCategoryLimits[catObj.name] ??
        customCategoryLimits[catId] ??
        fallbackLimit;

    final pct = (spentAmount / categoryBudgetLimit) * 100;

    if (pct >= 100) {
      final excess = spentAmount - categoryBudgetLimit;
      final excessStr = CurrencyFormatter.format(excess);
      final nudgeId = 'threshold_alert_$catId';
      if (!dismissedIds.contains(nudgeId)) {
        final en = 'Budget Alert: You have exceeded your $categoryNameEn limit by $excessStr. Let’s adjust other categories to stay on track!';
        final ro = 'Alertă de Buget: Ai depășit limita pentru $categoryNameRo cu $excessStr. Să ajustăm celelalte categorii pentru a rămâne pe cale!';
        candidates.add(
          WealthAdvisorState(
            id: nudgeId,
            title: 'BUDGET ALERT • ${categoryNameEn.toUpperCase()}',
            titleEn: 'BUDGET ALERT • ${categoryNameEn.toUpperCase()}',
            titleRo: 'ALERTĂ DE BUGET • ${categoryNameRo.toUpperCase()}',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.warning_amber_rounded,
            type: AdvisorType.insight,
            severity: NudgeSeverity.alert,
          ),
        );
      }
    } else if (pct >= 80) {
      final pctStr = pct.toStringAsFixed(0);
      final nudgeId = 'threshold_warning_$catId';
      if (!dismissedIds.contains(nudgeId)) {
        final en = 'Notice: You have used $pctStr% of your $categoryNameEn budget. Consider slowing down expenses here for the rest of the month.';
        final ro = 'Atenție: Ai consumat $pctStr% din bugetul pentru $categoryNameRo. Ia în calcul să încetinești cheltuielile aici până la sfârșitul lunii.';
        candidates.add(
          WealthAdvisorState(
            id: nudgeId,
            title: 'WARNING • ${categoryNameEn.toUpperCase()} ($pctStr%)',
            titleEn: 'WARNING • ${categoryNameEn.toUpperCase()} ($pctStr%)',
            titleRo: 'ATENȚIE • ${categoryNameRo.toUpperCase()} ($pctStr%)',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.error_outline,
            type: AdvisorType.insight,
            severity: NudgeSeverity.warning,
          ),
        );
      }
    } else if (pct < 50 && spentAmount > 0) {
      final nudgeId = 'threshold_safe_$catId';
      if (!dismissedIds.contains(nudgeId)) {
        final en = 'Great pacing! You are well under your budget for $categoryNameEn.';
        final ro = 'Ritm excelent! Ești mult sub bugetul stabilit pentru $categoryNameRo.';
        candidates.add(
          WealthAdvisorState(
            id: nudgeId,
            title: 'SAFE ZONE • ${categoryNameEn.toUpperCase()}',
            titleEn: 'SAFE ZONE • ${categoryNameEn.toUpperCase()}',
            titleRo: 'RITM EXCELENT • ${categoryNameRo.toUpperCase()}',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.check_circle_outline,
            type: AdvisorType.insight,
            severity: NudgeSeverity.safe,
          ),
        );
      }
    }
  });

  // 2. Evaluate Category Aggregates for Specific Behavioral Nudges
  int coffeeTeaCount = 0;
  double restaurantSpending = 0.0;
  int subscriptionCount = 0;
  double otherSpending = 0.0;
  double totalExpenseSum = 0.0;

  double creditInstallmentsSpending = 0.0;
  double groceriesSpending = 0.0;
  double salaryIncome = 0.0;
  double sideHustleIncome = 0.0;
  double mealTicketsIncome = 0.0;

  for (final tx in transactions) {
    final cat = defaultCategories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => Category(
        id: tx.categoryId ?? 'uncategorized',
        name: tx.categoryId == null ? 'other' : 'uncategorized',
        createdAt: DateTime.now(),
      ),
    );
    final desc = (tx.description ?? '').toLowerCase();
    final catName = cat.name.toLowerCase();

    if (tx.amount < 0) {
      final amt = tx.amount.abs();
      totalExpenseSum += amt;

      // Check coffee_tea
      if (tx.categoryId == '00000000-0000-0000-0000-000000000c10' ||
          catName == 'coffee_tea' ||
          catName == 'coffee & tea' ||
          desc.contains('starbucks') ||
          desc.contains('5togo') ||
          desc.contains('latte')) {
        coffeeTeaCount++;
      }

      // Check restaurants
      if (tx.categoryId == '00000000-0000-0000-0000-000000000c11' ||
          catName == 'restaurants' ||
          catName == 'restaurant') {
        restaurantSpending += amt;
      }

      // Check subscriptions
      if (tx.categoryId == '00000000-0000-0000-0000-000000000c13' ||
          catName == 'subscriptions' ||
          catName == 'subscription') {
        subscriptionCount++;
      }

      // Check other / uncategorized
      if (tx.categoryId == null ||
          tx.categoryId == '00000000-0000-0000-0000-000000000c14' ||
          catName == 'other' ||
          catName == 'uncategorized') {
        otherSpending += amt;
      }

      // Check credit_installments
      if (tx.categoryId == '00000000-0000-0000-0000-000000000c15' ||
          catName == 'credit_installments' ||
          catName == 'credit & loans' ||
          catName == 'rate & credite') {
        creditInstallmentsSpending += amt;
      }

      // Check groceries
      if (tx.categoryId == '00000000-0000-0000-0000-000000000c16' ||
          catName == 'groceries' ||
          catName == 'cumpărături casnice' ||
          catName == 'cumparaturi casnice') {
        groceriesSpending += amt;
      }
    } else if (tx.amount > 0) {
      // Check salary
      if (tx.categoryId == '00000000-0000-0000-0000-0000000000c5' ||
          catName == 'salary' ||
          catName == 'salariu') {
        salaryIncome += tx.amount;
      }

      // Check side_hustle
      if (tx.categoryId == '00000000-0000-0000-0000-000000000c18' ||
          catName == 'side_hustle' ||
          catName == 'side hustle' ||
          catName == 'proiecte extra') {
        sideHustleIncome += tx.amount;
      }

      // Check meal_tickets
      if (tx.categoryId == '00000000-0000-0000-0000-000000000c17' ||
          catName == 'meal_tickets' ||
          catName == 'meal tickets' ||
          catName == 'bonuri de masă' ||
          catName == 'bonuri de masa') {
        mealTicketsIncome += tx.amount;
      }
    }
  }

  // A. coffee_tea trigger (> 15 transactions/month) -> "Latte Factor"
  if (coffeeTeaCount > 15) {
    const nudgeId = 'nudge_coffee_tea_frequency';
    if (!dismissedIds.contains(nudgeId)) {
      const en = 'You have made over 15 coffee & tea purchases this month! Small daily cafe visits add up fast ("Latte Factor")—brewing at home can unlock significant annual savings.';
      const ro = 'Ai făcut peste 15 achiziții de cafea & ceai în această lună! Vizitele zilnice la cafenea se adună rapid ("Factorul Latte")—prepararea acasă poate debloca economii anuale semnificative.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • LATTE FACTOR',
          titleEn: 'BEHAVIORAL NUDGE • LATTE FACTOR',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • FACTORUL LATTE',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.local_cafe,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.warning,
        ),
      );
    }
  }

  // B. restaurants trigger (Ratio > 15% of total spending) -> Meal-prep vs delivery balance
  if (totalExpenseSum > 0 && (restaurantSpending / totalExpenseSum) > 0.15) {
    const nudgeId = 'nudge_restaurants_ratio';
    if (!dismissedIds.contains(nudgeId)) {
      const en = 'Restaurants & Dining account for over 15% of your total spending. Balancing dining out with meal-prepping at home helps preserve your savings surplus.';
      const ro = 'Restaurantele și mesele în oraș reprezintă peste 15% din cheltuielile tale totale. Balansarea meselor în oraș cu gătitul acasă ajută la menținerea surplusului.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • RESTAURANT SPENDING',
          titleEn: 'BEHAVIORAL NUDGE • RESTAURANT SPENDING',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • CHELTUIELI RESTAURANTE',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.restaurant,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.warning,
        ),
      );
    }
  }

  // C. subscriptions trigger (> 5 recurring items in 30 days) -> Unused service pruning
  if (subscriptionCount > 5) {
    const nudgeId = 'nudge_subscriptions_pruning';
    if (!dismissedIds.contains(nudgeId)) {
      const en = 'You have over 5 recurring subscription charges in the last 30 days. Pruning unused services and memberships is an instant way to eliminate waste.';
      const ro = 'Ai peste 5 taxe de abonament recurente în ultimele 30 de zile. Curățarea serviciilor și abonamentelor nefolosite este o cale rapidă de a elimina risipa.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • SUBSCRIPTION PRUNING',
          titleEn: 'BEHAVIORAL NUDGE • SUBSCRIPTION PRUNING',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • AUDIT ABONAMENTE',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.subscriptions,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.info,
        ),
      );
    }
  }

  // D. other trigger (> 20% spending uncategorized / other) -> Eliminate budget blind spots
  if (totalExpenseSum > 0 && (otherSpending / totalExpenseSum) > 0.20) {
    const nudgeId = 'nudge_other_uncategorized';
    if (!dismissedIds.contains(nudgeId)) {
      const en = 'Over 20% of your total spending is uncategorized or marked as Other. Tagging transactions eliminates budget blind spots and keeps your tracking accurate.';
      const ro = 'Peste 20% din cheltuielile tale sunt necategorisite sau marcate ca Altele. Etichetarea tranzacțiilor elimină punctele oarbe financiare și îți menține bugetul precis.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • BUDGET BLIND SPOTS',
          titleEn: 'BEHAVIORAL NUDGE • BUDGET BLIND SPOTS',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • PUNCTE OARBE BUGET',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.inventory_2,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.warning,
        ),
      );
    }
  }

  // E. Debt-to-Income Rule (credit_installments > 30% of (salary + side_hustle))
  final double totalPrimaryIncome = salaryIncome + sideHustleIncome;
  if (totalPrimaryIncome > 0 &&
      (creditInstallmentsSpending / totalPrimaryIncome) > 0.30) {
    const nudgeId = 'nudge_debt_to_income';
    if (!dismissedIds.contains(nudgeId)) {
      const en =
          'Your loan & credit installments exceed 30% of your income. Consider allocating extra cash flow toward early principal paydown.';
      const ro =
          'Ratele și creditele depășesc 30% din venituri. Se recomandă rambursarea anticipată a principalului.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • DEBT-TO-INCOME RATIO',
          titleEn: 'BEHAVIORAL NUDGE • DEBT-TO-INCOME RATIO',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • GRAD ÎNDATORARE',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.account_balance,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.warning,
        ),
      );
    }
  }

  // F. Food Ratio Rule (restaurants > 50% of groceries total)
  if (groceriesSpending > 0 &&
      (restaurantSpending / groceriesSpending) > 0.50) {
    const nudgeId = 'nudge_food_ratio';
    if (!dismissedIds.contains(nudgeId)) {
      const en =
          'Your restaurant spending exceeds 50% of your grocery budget. Shifting towards home-cooked meals could save significant capital.';
      const ro =
          'Cheltuielile la restaurante depășesc 50% din cumpărăturile casnice. Pregătirea meselor acasă poate aduce economii considerabile.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • FOOD RATIO',
          titleEn: 'BEHAVIORAL NUDGE • FOOD RATIO',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • RESTAURANTE VS CUMPĂRĂTURI',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.restaurant,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.warning,
        ),
      );
    }
  }

  // G. Ticket Allocation Rule (meal_tickets > 0 logged)
  if (mealTicketsIncome > 0) {
    const nudgeId = 'nudge_ticket_allocation';
    if (!dismissedIds.contains(nudgeId)) {
      const en =
          'You logged meal tickets this month. Use tickets strictly for food and grocery purchases to preserve your primary cash savings.';
      const ro =
          'Ai înregistrat bonuri de masă. Folosește-le exclusiv pentru alimente și cumpărături casnice pentru a-ți proteja disponibilul de numerar.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • MEAL TICKET ALLOCATION',
          titleEn: 'BEHAVIORAL NUDGE • MEAL TICKET ALLOCATION',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • OPTIMIZARE BONURI DE MASĂ',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.confirmation_number,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.info,
        ),
      );
    }
  }

  // H. Time Cost Rule (Clothing / Gadgets > 8 hours of work time)
  final double totalMonthlyIncome = salaryIncome + sideHustleIncome + mealTicketsIncome;
  final double baseIncomeForRate = totalMonthlyIncome > 0 ? totalMonthlyIncome : monthlyBudget;
  final double hourlyRate = baseIncomeForRate / 160.0;

  Transaction? highTimeCostTx;
  double highTimeCostHours = 0.0;
  String highTimeCostCatName = '';

  for (final tx in transactions) {
    if (tx.amount < 0) {
      final cat = defaultCategories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => Category(
          id: tx.categoryId ?? 'uncategorized',
          name: tx.categoryId == null ? 'other' : 'uncategorized',
          createdAt: DateTime.now(),
        ),
      );
      final catName = cat.name.toLowerCase();
      if (catName == 'clothing' || catName == 'gadgets') {
        final hours = tx.amount.abs() / (hourlyRate > 0 ? hourlyRate : 50.0);
        if (hours > 8.0 && hours > highTimeCostHours) {
          highTimeCostTx = tx;
          highTimeCostHours = hours;
          highTimeCostCatName = catName == 'clothing' ? 'Clothing' : 'Gadgets';
        }
      }
    }
  }

  if (highTimeCostTx != null) {
    const nudgeId = 'nudge_time_cost';
    if (!dismissedIds.contains(nudgeId)) {
      final amountStr = CurrencyFormatter.format(highTimeCostTx.amount.abs());
      final hoursStr = highTimeCostHours.toStringAsFixed(1);
      final en = 'Time Check: A purchase of $amountStr in $highTimeCostCatName cost over $hoursStr hours of work! Consider if this purchase delivers lasting value.';
      final ro = 'Verificarea Timpului: O achiziție de $amountStr la $highTimeCostCatName te-a costat peste $hoursStr ore de muncă! Verifică dacă această achiziție îți aduce valoare durabilă.';
      candidates.add(
        WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • TIME CHECK ($hoursStr hrs)',
          titleEn: 'BEHAVIORAL NUDGE • TIME CHECK ($hoursStr hrs)',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • VERIFICAREA TIMPULUI ($hoursStr ore)',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.access_time_rounded,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.warning,
        ),
      );
    }
  }

  // I. Positive Reinforcement Rule (Education transaction logged)
  bool hasEducationTx = false;
  for (final tx in transactions) {
    final cat = defaultCategories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => Category(
        id: tx.categoryId ?? 'uncategorized',
        name: tx.categoryId == null ? 'other' : 'uncategorized',
        createdAt: DateTime.now(),
      ),
    );
    final catName = cat.name.toLowerCase();
    if (catName == 'education' || catName == 'educație & dezvoltare' || catName == 'educatie & dezvoltare') {
      hasEducationTx = true;
      break;
    }
  }

  if (hasEducationTx) {
    const nudgeId = 'nudge_education_self_investment';
    if (!dismissedIds.contains(nudgeId)) {
      const en = 'Self-Investment: Congratulations on investing in your education! Up-skilling and continuous learning are the highest-return assets in your portfolio.';
      const ro = 'Investiție în Tine: Felicitări pentru investiția în educația și dezvoltarea ta! Perfecționarea continuă este cel mai rentabil activ din portofoliul tău.';
      candidates.add(
        const WealthAdvisorState(
          id: nudgeId,
          title: 'POSITIVE REINFORCEMENT • SELF-INVESTMENT',
          titleEn: 'POSITIVE REINFORCEMENT • SELF-INVESTMENT',
          titleRo: 'RECOMANDARE POZITIVĂ • INVESTIȚIE ÎN TINE',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.school,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.info,
        ),
      );
    }
  }

  // J. Sinking Fund Rule (Travel > 10% Income)
  double travelSpending = 0.0;
  for (final tx in transactions) {
    if (tx.amount < 0) {
      final cat = defaultCategories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => Category(
          id: tx.categoryId ?? 'uncategorized',
          name: tx.categoryId == null ? 'other' : 'uncategorized',
          createdAt: DateTime.now(),
        ),
      );
      final catName = cat.name.toLowerCase();
      if (catName == 'travel' || catName == 'călătorii & vacanțe' || catName == 'calatorii & vacante') {
        travelSpending += tx.amount.abs();
      }
    }
  }

  final double incomeThreshold = baseIncomeForRate * 0.10;
  if (travelSpending > 0 && travelSpending > incomeThreshold) {
    const nudgeId = 'nudge_travel_sinking_fund';
    if (!dismissedIds.contains(nudgeId)) {
      final travelStr = CurrencyFormatter.format(travelSpending);
      final en = 'Sinking Fund: Your travel expense ($travelStr) exceeded 10% of your monthly income. Setting up a dedicated monthly travel sinking fund will keep your holiday plans stress-free.';
      final ro = 'Fond de Rulaj: Cheltuiala ta de călătorie ($travelStr) a depășit 10% din venitul lunar. Crearea unui fond lunar dedicat pentru vacanțe te va ajuta să călătorești fără stres financiar.';
      candidates.add(
        WealthAdvisorState(
          id: nudgeId,
          title: 'BEHAVIORAL NUDGE • TRAVEL SINKING FUND',
          titleEn: 'BEHAVIORAL NUDGE • TRAVEL SINKING FUND',
          titleRo: 'RECOMANDARE COMPORTAMENTALĂ • FOND DE RULAJ VACANȚE',
          message: en,
          textEn: en,
          textRo: ro,
          icon: Icons.flight_takeoff,
          type: AdvisorType.nudge,
          severity: NudgeSeverity.info,
        ),
      );
    }
  }

  // 3. Evaluate Multi-Category Behavioral Nudges based on recent transaction text / keywords
  final sortedTx = List<Transaction>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  for (final tx in sortedTx) {
    if (tx.amount >= 0) continue;
    final text = (tx.description ?? '').toLowerCase();

    // A. Transport (Taxi / Rideshare)
    if ((text.contains('uber') && !text.contains('eats')) ||
        text.contains('bolt') ||
        text.contains('taxi') ||
        text.contains('rideshare')) {
      const nudgeId = 'nudge_transport_taxi';
      if (!dismissedIds.contains(nudgeId)) {
        const en = 'Taking a taxi is convenient, but to be friendly with nature and your future wealth, consider public transit next time!';
        const ro = 'Să iei un taxi este comod, dar pentru a fi prietenos cu natura și cu averea ta viitoare, ia în considerare transportul public data viitoare!';
        candidates.add(
          const WealthAdvisorState(
            id: nudgeId,
            title: 'BEHAVIORAL NUDGE • TRANSPORT',
            titleEn: 'BEHAVIORAL NUDGE • TRANSPORT',
            titleRo: 'RECOMANDARE COMPORTAMENTALĂ • TRANSPORT',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.local_taxi,
            type: AdvisorType.nudge,
            severity: NudgeSeverity.info,
          ),
        );
      }
    }

    // A. Transport (Public Transit)
    if (text.contains('stb') ||
        text.contains('metrorex') ||
        text.contains('bus') ||
        text.contains('train') ||
        text.contains('transit')) {
      const nudgeId = 'nudge_transport_transit';
      if (!dismissedIds.contains(nudgeId)) {
        const en = 'Great choice! You saved money by taking public transportation today.';
        const ro = 'Excelentă alegere! Ai economisit bani folosind transportul public astăzi.';
        candidates.add(
          const WealthAdvisorState(
            id: nudgeId,
            title: 'SAVINGS INSIGHT • TRANSPORT',
            titleEn: 'SAVINGS INSIGHT • TRANSPORT',
            titleRo: 'ECONOMII RECOMANDATE • TRANSPORT',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.directions_bus,
            type: AdvisorType.insight,
            severity: NudgeSeverity.safe,
          ),
        );
      }
    }

    // B. Food & Dining (Delivery / Restaurant)
    if (text.contains('uber eats') ||
        text.contains('glovo') ||
        text.contains('tazz') ||
        text.contains('bolt food') ||
        text.contains('mcdonalds') ||
        text.contains('kfc') ||
        text.contains('restaurant')) {
      const nudgeId = 'nudge_food_delivery';
      if (!dismissedIds.contains(nudgeId)) {
        const en = 'Dining out is a nice reward! Cooking at home a bit more this week can help boost your savings goal.';
        const ro = 'Să mănănci în oraș e o răsplată plăcută! Gătitul acasă puțin mai des în această săptămână te poate ajuta să-ți atingi obiectivul de economisire.';
        candidates.add(
          const WealthAdvisorState(
            id: nudgeId,
            title: 'BEHAVIORAL NUDGE • DINING OUT',
            titleEn: 'BEHAVIORAL NUDGE • DINING OUT',
            titleRo: 'RECOMANDARE COMPORTAMENTALĂ • MÂNCARE ÎN ORAȘ',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.restaurant,
            type: AdvisorType.nudge,
            severity: NudgeSeverity.info,
          ),
        );
      }
    }

    // B. Food & Dining (Groceries)
    if (text.contains('lidl') ||
        text.contains('kaufland') ||
        text.contains('mega image') ||
        text.contains('carrefour') ||
        text.contains('auchan') ||
        text.contains('profi') ||
        text.contains('groceries')) {
      const nudgeId = 'nudge_food_groceries';
      if (!dismissedIds.contains(nudgeId)) {
        const en = 'Smart investment in home-cooked meals! High-value spending for your wellness and budget.';
        const ro = 'Investiție inteligentă în mese gătite acasă! Cheltuială cu valoare mare pentru starea ta de bine și buget.';
        candidates.add(
          const WealthAdvisorState(
            id: nudgeId,
            title: 'SAVINGS INSIGHT • GROCERIES',
            titleEn: 'SAVINGS INSIGHT • GROCERIES',
            titleRo: 'INVESTIȚIE INTELIGENTĂ • CUMPĂRĂTURI',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.shopping_basket,
            type: AdvisorType.insight,
            severity: NudgeSeverity.safe,
          ),
        );
      }
    }

    // C. Entertainment & Subscriptions (Streaming / Subscriptions)
    if (text.contains('netflix') ||
        text.contains('spotify') ||
        text.contains('hbo') ||
        text.contains('youtube') ||
        text.contains('apple.com') ||
        text.contains('subscription')) {
      const nudgeId = 'nudge_entertainment_subscriptions';
      if (!dismissedIds.contains(nudgeId)) {
        const en = 'Review your active subscriptions periodically—canceling unused services is free compound interest!';
        const ro = 'Revizuiește-ți abonamentele active periodic—anularea serviciilor nefolosite este dobândă compusă gratuită!';
        candidates.add(
          const WealthAdvisorState(
            id: nudgeId,
            title: 'BEHAVIORAL NUDGE • SUBSCRIPTIONS',
            titleEn: 'BEHAVIORAL NUDGE • SUBSCRIPTIONS',
            titleRo: 'RECOMANDARE COMPORTAMENTALĂ • ABONAMENTE',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.subscriptions,
            type: AdvisorType.nudge,
            severity: NudgeSeverity.info,
          ),
        );
      }
    }

    // C. Entertainment & Subscriptions (Events / Leisure)
    if (text.contains('cinema') ||
        text.contains('concert') ||
        text.contains('eventim') ||
        text.contains('iabilet') ||
        text.contains('event') ||
        text.contains('leisure')) {
      const nudgeId = 'nudge_entertainment_events';
      if (!dismissedIds.contains(nudgeId)) {
        const en = 'Investing in memorable experiences brings long-term joy. Just ensure it aligns with your monthly fun budget!';
        const ro = 'Investiția în experiențe memorabile aduce bucurie pe termen lung. Doar asigură-te că se încadrează în bugetul tău de distracție!';
        candidates.add(
          const WealthAdvisorState(
            id: nudgeId,
            title: 'SAVINGS INSIGHT • LEISURE',
            titleEn: 'SAVINGS INSIGHT • LEISURE',
            titleRo: 'ANALIZĂ COMPORTAMENTALĂ • TIMP LIBER',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.confirmation_number,
            type: AdvisorType.insight,
            severity: NudgeSeverity.info,
          ),
        );
      }
    }

    // D. Shopping & Lifestyle (Impulse / Non-Essential)
    if (text.contains('zara') ||
        text.contains('h&m') ||
        text.contains('emag') ||
        text.contains('about you') ||
        text.contains('answear') ||
        text.contains('amazon') ||
        text.contains('shopping') ||
        text.contains('impulse')) {
      const nudgeId = 'nudge_shopping_lifestyle';
      if (!dismissedIds.contains(nudgeId)) {
        const en = 'Pause before the next purchase! Applying the 24-hour rule on non-essentials can save you hundreds each year.';
        const ro = 'Fă o pauză înainte de următoarea cumpărătură! Aplicarea regulii de 24 de ore pentru lucrurile neesențiale îți poate economisi sute de lei/euro anual.';
        candidates.add(
          const WealthAdvisorState(
            id: nudgeId,
            title: 'BEHAVIORAL NUDGE • SHOPPING',
            titleEn: 'BEHAVIORAL NUDGE • SHOPPING',
            titleRo: 'RECOMANDARE COMPORTAMENTALĂ • CUMPĂRĂTURI',
            message: en,
            textEn: en,
            textRo: ro,
            icon: Icons.shopping_bag,
            type: AdvisorType.nudge,
            severity: NudgeSeverity.warning,
          ),
        );
      }
    }
  }

  if (candidates.isEmpty) return null;

  // Sort by priority severity: alert > warning > info > safe
  candidates.sort((a, b) {
    const priorityMap = {
      NudgeSeverity.alert: 0,
      NudgeSeverity.warning: 1,
      NudgeSeverity.info: 2,
      NudgeSeverity.safe: 3,
    };
    return priorityMap[a.severity]!.compareTo(priorityMap[b.severity]!);
  });

  return candidates.first;
});
