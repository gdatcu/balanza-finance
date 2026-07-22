import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/transaction.dart';
import '../../../models/category.dart';
import '../../../models/category_summary.dart';
import '../repositories/transaction_repository.dart';
import '../presentation/categories_data.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/net_worth_item.dart';
import '../../net_worth/providers/net_worth_provider.dart';
import '../../auth/providers/auth_provider.dart';

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
    // Rebuild the budget whenever the user's authentication state changes
    ref.watch(authProvider);

    final prefs = ref.watch(sharedPreferencesProvider);
    final localBudget = prefs.getDouble(_key) ?? 1000.0;

    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId != null) {
        _loadFromSupabase(client, currentUserId, localBudget);
      }
    } catch (_) {
      // Gracefully handle uninitialized Supabase (e.g. in tests)
    }

    return localBudget;
  }

  Future<void> _loadFromSupabase(SupabaseClient client, String userId, double localBudget) async {
    try {
      final response = await client
          .from('budgets')
          .select('limit_amount')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['limit_amount'] != null) {
        state = (response['limit_amount'] as num).toDouble();
      } else {
        // If no budget row exists in Supabase, sync the local budget to Supabase
        await client.from('budgets').upsert({
          'user_id': userId,
          'limit_amount': localBudget,
        }, onConflict: 'user_id');
      }
    } catch (_) {
      // Gracefully catch database missing table errors before user runs SQL console script
    }
  }

  Future<bool> update(double value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final success = await prefs.setDouble(_key, value);
    state = value;

    try {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId != null) {
        await client.from('budgets').upsert({
          'user_id': currentUserId,
          'limit_amount': value,
        }, onConflict: 'user_id');
      }
    } catch (_) {}

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

/// Provider for generating dynamic, data-driven financial insights.
final insightsProvider = Provider<String>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final netWorthAsync = ref.watch(netWorthListProvider);
  final budget = ref.watch(monthlyBudgetProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  final netWorthItems = netWorthAsync.value ?? const <NetWorthItem>[];

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      // 1. Month-over-Month Net Worth Growth Check (Highest priority)
      final currentMonthItems = netWorthItems.where((item) =>
          item.createdAt.year == selectedMonth.year &&
          item.createdAt.month == selectedMonth.month).toList();

      final previousMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      final previousMonthItems = netWorthItems.where((item) =>
          item.createdAt.year == previousMonth.year &&
          item.createdAt.month == previousMonth.month).toList();

      if (currentMonthItems.isNotEmpty) {
        final currentAssets = currentMonthItems
            .where((item) => item.type == NetWorthType.asset)
            .fold<double>(0.0, (sum, item) => sum + item.balance);
        final currentLiabilities = currentMonthItems
            .where((item) => item.type == NetWorthType.liability)
            .fold<double>(0.0, (sum, item) => sum + item.balance);
        final currentNetWorth = currentAssets - currentLiabilities;

        final previousAssets = previousMonthItems
            .where((item) => item.type == NetWorthType.asset)
            .fold<double>(0.0, (sum, item) => sum + item.balance);
        final previousLiabilities = previousMonthItems
            .where((item) => item.type == NetWorthType.liability)
            .fold<double>(0.0, (sum, item) => sum + item.balance);
        final previousNetWorth = previousAssets - previousLiabilities;

        if (currentNetWorth > previousNetWorth) {
          final diff = currentNetWorth - previousNetWorth;
          final diffStr = diff.toStringAsFixed(2);
          return 'Excellent work. Your net worth grew by $diffStr RON this month. Why it matters: This is the ultimate metric of financial momentum. Every positive increase means you are actively buying back your future time and building a permanent safety net.';
        }
      }

      final totalExpenses = transactions
          .where((tx) => tx.amount < 0)
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);

      final totalIncome = transactions
          .where((tx) => tx.amount > 0)
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);

      final budgetSpentPercentage = budget > 0 ? (totalExpenses.abs() / budget) * 100 : 0.0;

      // 2. High Surplus (Expenses < 20% of Income)
      if (totalIncome > 0 && totalExpenses.abs() < 0.20 * totalIncome) {
        final savingsPercentage = ((totalIncome - totalExpenses.abs()) / totalIncome * 100).toStringAsFixed(1);
        return 'Outstanding! You saved $savingsPercentage% of your income this month. Why it matters: A high savings rate creates a compounding capital surplus, buying you control over your future time.';
      }

      // 3. High Expense Warning (Budget > 90%)
      if (budget > 0 && budgetSpentPercentage > 90) {
        final y = budgetSpentPercentage.toStringAsFixed(1);
        return 'You have utilized $y% of your budget. Why it matters: Small daily leaks sink great ships. Reeling in discretionary spending now prevents a deficit and keeps your wealth-building engine running.';
      }

      // 4. On Track Budget (Budget < 50% mid-month)
      if (budget > 0 && budgetSpentPercentage < 50) {
        final y = budgetSpentPercentage.toStringAsFixed(1);
        final budgetAmount = CurrencyFormatter.format(budget);
        return 'You are at $y% of your $budgetAmount budget. On track for a strong surplus. Why it matters: Consistently beating your budget prevents lifestyle creep and builds the cash runway needed to take calculated risks.';
      }

      // Default/neutral insight if none of the above are met
      return 'Keep tracking your transactions to gain control over your money. Why it matters: Consistent monitoring is the first step toward optimization and financial freedom.';
    },
    orElse: () => 'Analyzing your finances... Why it matters: Patience and continuous tracking are key to understanding your long-term wealth trajectory.',
  );
});
