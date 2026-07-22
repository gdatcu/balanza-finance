import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/transaction.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/presentation/categories_data.dart';
import '../models/advisor_nudge.dart';

/// StateNotifier to track dismissed nudge IDs.
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

/// Provider for computing universal wealth advisor behavioral nudges.
final wealthAdvisorProvider = Provider<AdvisorNudge?>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final monthlyBudget = ref.watch(monthlyBudgetProvider);
  final dismissedIds = ref.watch(dismissedNudgesProvider);

  final transactions = transactionsAsync.value ?? <Transaction>[];
  if (transactions.isEmpty) return null;

  final List<AdvisorNudge> generatedNudges = [];

  // 1. Group expense transactions by category
  final Map<String, double> categoryExpenses = {};
  for (final tx in transactions) {
    if (tx.amount < 0) {
      final catId = tx.categoryId ?? 'uncategorized';
      categoryExpenses[catId] = (categoryExpenses[catId] ?? 0.0) + tx.amount.abs();
    }
  }

  // Estimate per-category budget limit (e.g. allocated proportionally or default share)
  final double categoryBudgetLimit = monthlyBudget > 0 ? (monthlyBudget / 3.0) : 300.0;

  // Evaluate Universal Budget Threshold Engine for each category
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
        generatedNudges.add(
          AdvisorNudge(
            id: nudgeId,
            categoryName: categoryName,
            icon: Icons.warning_amber_rounded,
            severity: NudgeSeverity.alert,
            textEn: 'Budget Alert: You have exceeded your $categoryName limit by $excessStr. Let’s adjust other categories to stay on track!',
            textRo: 'Alertă de Buget: Ai depășit limita pentru $categoryName cu $excessStr. Să ajustăm celelalte categorii pentru a rămâne pe cale!',
          ),
        );
      }
    } else if (pct >= 80) {
      final pctStr = pct.toStringAsFixed(0);
      final nudgeId = 'threshold_warning_$catId';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          AdvisorNudge(
            id: nudgeId,
            categoryName: categoryName,
            icon: Icons.error_outline,
            severity: NudgeSeverity.warning,
            textEn: 'Notice: You have used $pctStr% of your $categoryName budget. Consider slowing down expenses here for the rest of the month.',
            textRo: 'Atenție: Ai consumat $pctStr% din bugetul pentru $categoryName. Ia în calcul să încetinești cheltuielile aici până la sfârșitul lunii.',
          ),
        );
      }
    } else if (pct < 50 && spentAmount > 0) {
      final nudgeId = 'threshold_safe_$catId';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          AdvisorNudge(
            id: nudgeId,
            categoryName: categoryName,
            icon: Icons.check_circle_outline,
            severity: NudgeSeverity.safe,
            textEn: 'Great pacing! You are well under your budget for $categoryName.',
            textRo: 'Ritm excelent! Ești mult sub bugetul stabilit pentru $categoryName.',
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

    // A. Transport Nudges
    if (text.contains('uber') && !text.contains('eats') ||
        text.contains('bolt') ||
        text.contains('taxi') ||
        text.contains('rideshare')) {
      const nudgeId = 'nudge_transport_taxi';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          const AdvisorNudge(
            id: nudgeId,
            categoryName: 'Transport',
            icon: Icons.local_taxi,
            severity: NudgeSeverity.info,
            textEn: 'Taking a taxi is convenient, but to be friendly with nature and your future wealth, consider public transit next time!',
            textRo: 'Să iei un taxi este comod, dar pentru a fi prietenos cu natura și cu averea ta viitoare, ia în considerare transportul public data viitoare!',
          ),
        );
      }
    }

    if (text.contains('stb') ||
        text.contains('metrorex') ||
        text.contains('bus') ||
        text.contains('train') ||
        text.contains('transit')) {
      const nudgeId = 'nudge_transport_transit';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          const AdvisorNudge(
            id: nudgeId,
            categoryName: 'Transport',
            icon: Icons.directions_bus,
            severity: NudgeSeverity.safe,
            textEn: 'Great choice! You saved money by taking public transportation today.',
            textRo: 'Excelentă alegere! Ai economisit bani folosind transportul public astăzi.',
          ),
        );
      }
    }

    // B. Food & Dining Nudges
    if (text.contains('uber eats') ||
        text.contains('glovo') ||
        text.contains('tazz') ||
        text.contains('restaurant') ||
        text.contains('dining') ||
        text.contains('mcdonalds')) {
      const nudgeId = 'nudge_food_delivery';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          const AdvisorNudge(
            id: nudgeId,
            categoryName: 'Food',
            icon: Icons.restaurant,
            severity: NudgeSeverity.info,
            textEn: 'Dining out is a nice reward! Cooking at home a bit more this week can help boost your savings goal.',
            textRo: 'Să mănânci în oraș e o răsplată plăcută! Gătitul acasă puțin mai des în această săptămână te poate ajuta să-ți atingi obiectivul de economisire.',
          ),
        );
      }
    }

    if (text.contains('lidl') ||
        text.contains('kaufland') ||
        text.contains('mega image') ||
        text.contains('carrefour') ||
        text.contains('groceries')) {
      const nudgeId = 'nudge_food_groceries';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          const AdvisorNudge(
            id: nudgeId,
            categoryName: 'Food',
            icon: Icons.shopping_basket,
            severity: NudgeSeverity.safe,
            textEn: 'Smart investment in home-cooked meals! High-value spending for your wellness and budget.',
            textRo: 'Investiție inteligentă în mese gătite acasă! Cheltuială cu valoare mare pentru starea ta de bine și buget.',
          ),
        );
      }
    }

    // C. Entertainment & Subscriptions Nudges
    if (text.contains('netflix') ||
        text.contains('spotify') ||
        text.contains('hbo') ||
        text.contains('subscription') ||
        text.contains('youtube')) {
      const nudgeId = 'nudge_entertainment_subscription';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          const AdvisorNudge(
            id: nudgeId,
            categoryName: 'Entertainment',
            icon: Icons.subscriptions,
            severity: NudgeSeverity.info,
            textEn: 'Review your active subscriptions periodically—canceling unused services is free compound interest!',
            textRo: 'Revizuiește-ți abonamentele active periodic—anularea serviciilor nefolosite este dobindă compusă gratuită!',
          ),
        );
      }
    }

    if (text.contains('cinema') ||
        text.contains('concert') ||
        text.contains('event') ||
        text.contains('leisure')) {
      const nudgeId = 'nudge_entertainment_event';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          const AdvisorNudge(
            id: nudgeId,
            categoryName: 'Entertainment',
            icon: Icons.confirmation_number,
            severity: NudgeSeverity.info,
            textEn: 'Investing in memorable experiences brings long-term joy. Just ensure it aligns with your monthly fun budget!',
            textRo: 'Investiția în experiențe memorabile aduce bucurie pe termen lung. Doar asigură-te că se încadrează în bugetul tău de distracție!',
          ),
        );
      }
    }

    // D. Shopping & Lifestyle Nudges
    if (text.contains('zara') ||
        text.contains('fashion') ||
        text.contains('emag') ||
        text.contains('shopping') ||
        text.contains('impulse')) {
      const nudgeId = 'nudge_shopping_lifestyle';
      if (!dismissedIds.contains(nudgeId)) {
        generatedNudges.add(
          const AdvisorNudge(
            id: nudgeId,
            categoryName: 'Shopping',
            icon: Icons.shopping_bag,
            severity: NudgeSeverity.warning,
            textEn: 'Pause before the next purchase! Applying the 24-hour rule on non-essentials can save you hundreds each year.',
            textRo: 'Fă o pauză înainte de următoarea cumpărătură! Aplicarea regulii de 24 de ore pentru lucrurile neesențiale îți poate economisi sute de lei/euro anual.',
          ),
        );
      }
    }
  }

  if (generatedNudges.isEmpty) return null;

  // Sort by priority severity: alert > warning > info (behavioral nudge) > safe (general pacing)
  generatedNudges.sort((a, b) {
    const priorityMap = {
      NudgeSeverity.alert: 0,
      NudgeSeverity.warning: 1,
      NudgeSeverity.info: 2,
      NudgeSeverity.safe: 3,
    };
    return priorityMap[a.severity]!.compareTo(priorityMap[b.severity]!);
  });

  return generatedNudges.first;
});
