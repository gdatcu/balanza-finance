import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Target maximum budget percentages per category
const Map<String, double> smartCategoryMaxPercentages = {
  'groceries': 0.25,
  'rent': 0.30,
  'utilities': 0.10,
  'transport': 0.10,
  'credit_installments': 0.15,
  'clothing': 0.05,
  'entertainment': 0.05,
  'healthcare': 0.05,
  'gadgets': 0.05,
  'travel': 0.05,
  'personal_care': 0.05,
  'education': 0.05,
  'coffee_tea': 0.03,
  'restaurants': 0.08,
  'subscriptions': 0.03,
  'other': 0.05,
};

/// Riverpod provider returning recommended smart budget limits per category based on user income.
final smartBudgetSuggestionsProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionListProvider).value ?? [];
  final monthlyBudget = ref.watch(monthlyBudgetProvider).value ?? 1000.0;

  double totalIncome = 0.0;
  for (final tx in transactions) {
    if (tx.amount > 0) {
      totalIncome += tx.amount;
    }
  }

  final baseIncome = totalIncome > 0 ? totalIncome : monthlyBudget;

  final Map<String, double> suggestions = {};
  smartCategoryMaxPercentages.forEach((category, percentage) {
    suggestions[category] = baseIncome * percentage;
  });

  return suggestions;
});
