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
  final monthlyBudget = ref.watch(monthlyBudgetProvider);
  final dismissedIds = ref.watch(dismissedNudgesProvider);

  final transactions = transactionsAsync.value ?? <Transaction>[];
  if (transactions.isEmpty) return null;

  final List<WealthAdvisorState> candidates = [];

  // 1. Evaluate universal category budget thresholds (Warning at 80% usage, Alert at 100%)
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
    }
  });

  // 2. Evaluate 'Transport' budget (Taxi vs. Public Transit) and behavioral nudges
  final sortedTx = List<Transaction>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  for (final tx in sortedTx) {
    if (tx.amount >= 0) continue;
    final text = (tx.description ?? '').toLowerCase();

    // Transport (Taxi / Rideshare)
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

    // Transport (Public Transit)
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

    // Food Delivery
    if (text.contains('uber eats') ||
        text.contains('glovo') ||
        text.contains('tazz') ||
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
