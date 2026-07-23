import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/transaction.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/presentation/categories_data.dart';
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
  final Map<String, double> categoryExpenses = {};
  for (final tx in transactions) {
    if (tx.amount < 0) {
      final catId = tx.categoryId ?? 'uncategorized';
      categoryExpenses[catId] = (categoryExpenses[catId] ?? 0.0) + tx.amount.abs();
    }
  }

  final double categoryBudgetLimit = monthlyBudget > 0 ? (monthlyBudget / 3.0) : 300.0;

  categoryExpenses.forEach((catId, spentAmount) {
    final catObj = defaultCategories.firstWhere(
      (c) => c.id == catId,
      orElse: () => defaultCategories.first,
    );
    final categoryName = catObj.name;
    final pct = (spentAmount / categoryBudgetLimit) * 100;

    if (pct >= 100) {
      final excess = spentAmount - categoryBudgetLimit;
      final excessStr = CurrencyFormatter.format(excess);
      final nudgeId = 'threshold_alert_$catId';
      if (!dismissedIds.contains(nudgeId)) {
        final en = 'Budget Alert: You have exceeded your $categoryName limit by $excessStr. Let’s adjust other categories to stay on track!';
        final ro = 'Alertă de Buget: Ai depășit limita pentru $categoryName cu $excessStr. Să ajustăm celelalte categorii pentru a rămâne pe cale!';
        candidates.add(
          WealthAdvisorState(
            id: nudgeId,
            title: 'BUDGET ALERT • ${categoryName.toUpperCase()}',
            titleEn: 'BUDGET ALERT • ${categoryName.toUpperCase()}',
            titleRo: 'ALERTĂ DE BUGET • ${categoryName.toUpperCase()}',
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
        final en = 'Notice: You have used $pctStr% of your $categoryName budget. Consider slowing down expenses here for the rest of the month.';
        final ro = 'Atenție: Ai consumat $pctStr% din bugetul pentru $categoryName. Ia în calcul să încetinești cheltuielile aici până la sfârșitul lunii.';
        candidates.add(
          WealthAdvisorState(
            id: nudgeId,
            title: 'WARNING • ${categoryName.toUpperCase()} ($pctStr%)',
            titleEn: 'WARNING • ${categoryName.toUpperCase()} ($pctStr%)',
            titleRo: 'ATENȚIE • ${categoryName.toUpperCase()} ($pctStr%)',
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
        final en = 'Great pacing! You are well under your budget for $categoryName.';
        final ro = 'Ritm excelent! Ești mult sub bugetul stabilit pentru $categoryName.';
        candidates.add(
          WealthAdvisorState(
            id: nudgeId,
            title: 'SAFE ZONE • ${categoryName.toUpperCase()}',
            titleEn: 'SAFE ZONE • ${categoryName.toUpperCase()}',
            titleRo: 'RITM EXCELENT • ${categoryName.toUpperCase()}',
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

  // 2. Evaluate Multi-Category Behavioral Nudges based on recent transaction text / keywords
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
