import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/transaction.dart';
import '../../../models/category.dart';
import '../../../models/category_summary.dart';
import '../repositories/transaction_repository.dart';
import '../presentation/categories_data.dart';

/// Provider for SharedPreferences instance. Must be overridden at app launch.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

/// Provider for the TransactionRepository.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void update(DateTime value) {
    state = value;
  }
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(() {
  return SelectedMonthNotifier();
});

class MonthlyBudgetNotifier extends Notifier<double> {
  static const _key = 'monthly_budget_limit';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getDouble(_key) ?? 1000.0;
  }

  Future<bool> update(double value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final success = await prefs.setDouble(_key, value);
    state = value;
    return success;
  }
}

final monthlyBudgetProvider = NotifierProvider<MonthlyBudgetNotifier, double>(() {
  return MonthlyBudgetNotifier();
});

/// AsyncNotifier to manage state, loading/error states, and updates to the transactions list.
class TransactionListNotifier extends AsyncNotifier<List<Transaction>> {
  TransactionRepository get _repository => ref.read(transactionRepositoryProvider);

  @override
  Future<List<Transaction>> build() async {
    final selectedMonth = ref.watch(selectedMonthProvider);
    return ref.watch(transactionRepositoryProvider).getTransactions(selectedMonth);
  }

  /// Adds a new transaction and updates the state by refetching the active month's data.
  Future<void> add(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addTransaction(transaction);
      final selectedMonth = ref.read(selectedMonthProvider);
      return _repository.getTransactions(selectedMonth);
    });
  }

  /// Updates an existing transaction in the database and refetches the active month's data.
  Future<void> updateTx(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateTransaction(transaction);
      final selectedMonth = ref.read(selectedMonthProvider);
      return _repository.getTransactions(selectedMonth);
    });
  }

  /// Deletes a transaction and refetches the active month's data.
  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTransaction(id);
      final selectedMonth = ref.read(selectedMonthProvider);
      return _repository.getTransactions(selectedMonth);
    });
  }
}

/// Provider for the TransactionListNotifier.
final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(() {
  return TransactionListNotifier();
});

/// Provider to fetch categories dynamically from Supabase.
final supabaseCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final client = Supabase.instance.client;
  final response = await client.from('categories').select();
  return (response as List)
      .map((json) => Category.fromJson(json as Map<String, dynamic>))
      .toList();
});

/// Provider for Category Summaries, aggregating transactions by category for the current month.
final categorySummaryProvider = Provider<AsyncValue<List<CategorySummary>>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  return transactionsAsync.whenData((transactions) {
    final Map<String, double> sums = {};

    for (final tx in transactions) {
      final cat = defaultCategories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => defaultCategories.first,
      );
      final categoryName = cat.name;
      sums[categoryName] = (sums[categoryName] ?? 0.0) + tx.amount;
    }

    final summaries = sums.entries.map((entry) {
      final categoryName = entry.key;
      final amount = entry.value;
      final type = amount >= 0 ? TransactionType.income : TransactionType.expense;
      return CategorySummary(
        categoryName: categoryName,
        totalAmount: amount,
        transactionType: type,
      );
    }).toList();

    // Sort by totalAmount in descending order of absolute value (highest expenses/incomes at the top)
    summaries.sort((a, b) => b.totalAmount.abs().compareTo(a.totalAmount.abs()));

    return summaries;
  });
});
