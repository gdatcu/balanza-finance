import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/category.dart';
import '../../../models/category_budget.dart';
import '../../../models/transaction.dart';
import '../../transactions/presentation/categories_data.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../repositories/category_budget_repository.dart';

class CategoryBudgetProgress {
  final Category category;
  final CategoryBudget budget;
  final double currentSpent;
  final double amountLimit;
  final double percentageUsed;

  const CategoryBudgetProgress({
    required this.category,
    required this.budget,
    required this.currentSpent,
    required this.amountLimit,
    required this.percentageUsed,
  });

  bool get isOverBudget => percentageUsed >= 100;
  bool get isWarning => percentageUsed >= 75 && percentageUsed < 100;
  bool get isSafe => percentageUsed < 75;
}

final categoryBudgetProgressProvider = Provider<List<CategoryBudgetProgress>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final budgetsAsync = ref.watch(categoryBudgetsStreamProvider);

  final transactions = transactionsAsync.value ?? <Transaction>[];
  final budgets = budgetsAsync.value ?? <CategoryBudget>[];

  if (budgets.isEmpty) return <CategoryBudgetProgress>[];

  // Sum monthly expenses (amount < 0) per canonical category ID (no double counting)
  final Map<String, double> categorySpent = {};
  for (final tx in transactions) {
    if (tx.amount < 0) {
      final rawCatId = tx.categoryId ?? 'uncategorized';
      final catObj = defaultCategories.firstWhere(
        (c) => c.id == rawCatId || c.name.toLowerCase() == rawCatId.toLowerCase(),
        orElse: () => Category(id: rawCatId, name: rawCatId, createdAt: DateTime.now()),
      );
      categorySpent[catObj.id] = (categorySpent[catObj.id] ?? 0.0) + tx.amount.abs();
    }
  }

  final List<CategoryBudgetProgress> result = [];

  for (final budget in budgets) {
    // Find matching Category object
    final catObj = defaultCategories.firstWhere(
      (c) => c.id == budget.category || c.name.toLowerCase() == budget.category.toLowerCase(),
      orElse: () => Category(
        id: budget.category,
        name: budget.category,
        createdAt: DateTime.now(),
      ),
    );

    final spent = categorySpent[catObj.id] ?? 0.0;
    final pct = budget.amountLimit > 0 ? (spent / budget.amountLimit) * 100 : 0.0;

    result.add(
      CategoryBudgetProgress(
        category: catObj,
        budget: budget,
        currentSpent: spent,
        amountLimit: budget.amountLimit,
        percentageUsed: pct,
      ),
    );
  }

  // Sort by percentage used descending (highest percentage / over budget first)
  result.sort((a, b) => b.percentageUsed.compareTo(a.percentageUsed));

  return result;
});
