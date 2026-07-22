import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/transaction_provider.dart';
import '../../../models/transaction.dart';
import '../../../models/category_summary.dart';
import '../../../core/utils/currency_formatter.dart';
import 'transaction_input_sheet.dart';
import 'categories_data.dart';
import '../../analytics/presentation/expense_pie_chart.dart';
import '../../settings/presentation/settings_view.dart';

enum ToshlSection {
  overview,
  expenses,
  incomes,
  budgets,
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  ToshlSection _section = ToshlSection.overview;

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const TransactionInputSheet(),
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> groups = {};
    for (final tx in transactions) {
      final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!groups.containsKey(dateOnly)) {
        groups[dateOnly] = [];
      }
      groups[dateOnly]!.add(tx);
    }
    final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, groups[key]!..sort((a, b) => b.date.compareTo(a.date)))),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final compareDate = DateTime(date.year, date.month, date.day);

    if (compareDate == today) {
      return 'Today';
    } else if (compareDate == yesterday) {
      return 'Yesterday';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final wday = weekdays[date.weekday - 1];
      final month = months[date.month - 1];
      return '$wday, $month ${date.day}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    Color indicatorColor = const Color(0xFFFF7A5A); // Coral Orange for Expenses/FAB/Overview
    if (_section == ToshlSection.incomes) {
      indicatorColor = const Color(0xFF10B981); // Sage Mint for incomes
    } else if (_section == ToshlSection.budgets) {
      indicatorColor = const Color(0xFFF59E0B); // Warm Gold for budgets
    }

    String userEmail = 'personal.finance@toshl.com';
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null && currentUser.email != null) {
        userEmail = currentUser.email!;
      }
    } catch (_) {
      // Supabase is not initialized (e.g. in tests)
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text(
            'Balanza Finance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                indicatorColor: indicatorColor,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'BY DATE'),
                  Tab(text: 'BY CATEGORY'),
                ],
              ),
            ),
          ),
        ),
        drawer: Drawer(
          child: Container(
            color: const Color(0xFF0F172A),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFFFF7A5A),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Balanza Finance',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.dashboard,
                    color: _section == ToshlSection.overview ? const Color(0xFFFF7A5A) : Colors.grey,
                  ),
                  title: const Text('Monthly overview', style: TextStyle(color: Colors.white)),
                  selected: _section == ToshlSection.overview,
                  selectedTileColor: Colors.white.withValues(alpha: 0.05),
                  onTap: () {
                    setState(() {
                      _section = ToshlSection.overview;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_down, color: Color(0xFFFF7A5A)),
                  title: const Text('Expenses', style: TextStyle(color: Color(0xFFFF7A5A))),
                  selected: _section == ToshlSection.expenses,
                  selectedTileColor: const Color(0xFFFF7A5A).withValues(alpha: 0.05),
                  onTap: () {
                    setState(() {
                      _section = ToshlSection.expenses;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_up, color: Color(0xFF10B981)),
                  title: const Text('Incomes', style: TextStyle(color: Color(0xFF10B981))),
                  selected: _section == ToshlSection.incomes,
                  selectedTileColor: const Color(0xFF10B981).withValues(alpha: 0.05),
                  onTap: () {
                    setState(() {
                      _section = ToshlSection.incomes;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.pie_chart, color: Color(0xFFF59E0B)),
                  title: const Text('Budgets', style: TextStyle(color: Color(0xFFF59E0B))),
                  selected: _section == ToshlSection.budgets,
                  selectedTileColor: const Color(0xFFF59E0B).withValues(alpha: 0.05),
                  onTap: () {
                    setState(() {
                      _section = ToshlSection.budgets;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.grey),
                  title: const Text('Settings', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsView()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: transactionsAsync.when(
              data: (transactions) => TabBarView(
                children: [
                  _buildByDateTab(transactions),
                  _buildByCategoryTab(transactions),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF7A5A)),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong: $err',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(transactionListProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A5A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTransaction(context),
          backgroundColor: const Color(0xFFFF7A5A),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildByDateTab(List<Transaction> transactions) {
    final filtered = transactions.where((tx) {
      switch (_section) {
        case ToshlSection.overview:
          return true;
        case ToshlSection.expenses:
          return tx.amount < 0;
        case ToshlSection.incomes:
          return tx.amount > 0;
        case ToshlSection.budgets:
          return tx.amount < 0;
      }
    }).toList();

    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    for (final tx in transactions) {
      if (tx.amount > 0) {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount;
      }
    }
    final totalBalance = totalIncome + totalExpenses;

    final grouped = _groupTransactionsByDate(filtered);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        _buildMonthSelector(),

        if (_section == ToshlSection.overview) ...[
          _buildOverviewCard(totalBalance, totalIncome, totalExpenses),
          const SizedBox(height: 16),
          _buildBudgetCard(totalExpenses.abs()),
          const SizedBox(height: 16),
        ] else if (_section == ToshlSection.expenses) ...[
          _buildSectionSummary('Total Expenses', totalExpenses.abs(), const Color(0xFFFF7A5A)),
          const SizedBox(height: 16),
        ] else if (_section == ToshlSection.incomes) ...[
          _buildSectionSummary('Total Income', totalIncome, const Color(0xFF10B981)),
          const SizedBox(height: 16),
        ] else if (_section == ToshlSection.budgets) ...[
          _buildBudgetCard(totalExpenses.abs()),
          const SizedBox(height: 16),
        ],

        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: _buildEmptyState(),
          )
        else
          ...grouped.entries.expand((entry) {
            final date = entry.key;
            final txList = entry.value;
            return [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text(
                  _formatDateHeader(date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...txList.map((tx) => _buildTransactionRow(tx)),
            ];
          }),
      ],
    );
  }

  Widget _buildByCategoryTab(List<Transaction> transactions) {
    final isIncomeView = _section == ToshlSection.incomes;
    final summariesAsync = ref.watch(categorySummaryProvider);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        _buildMonthSelector(),
        const SizedBox(height: 8),
        ExpensePieChart(
          customTransactions: transactions,
          isIncome: isIncomeView,
        ),
        const SizedBox(height: 16),
        summariesAsync.when(
          data: (summaries) {
            final filtered = summaries.where((s) {
              if (isIncomeView) {
                return s.transactionType == TransactionType.income;
              } else {
                return s.transactionType == TransactionType.expense;
              }
            }).toList();

            if (filtered.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No categories with transactions in this section.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final color = isIncomeView ? const Color(0xFF10B981) : const Color(0xFFFF7A5A);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  title: Text(
                    item.categoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Text(
                    item.totalAmount > 0
                        ? '+${CurrencyFormatter.format(item.totalAmount)}'
                        : CurrencyFormatter.format(item.totalAmount),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, __) => Text(
            'Error: $err',
            style: const TextStyle(color: Color(0xFFFF7A5A)),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final String monthText = "${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).update(
                  DateTime(selectedMonth.year, selectedMonth.month - 1));
            },
          ),
          Text(
            monthText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).update(
                  DateTime(selectedMonth.year, selectedMonth.month + 1));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    double totalBalance,
    double totalIncome,
    double totalExpenses,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Colors.white12),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF10B981),
                  label: 'Income',
                  amount: totalIncome,
                ),
                _buildSummaryItem(
                  icon: Icons.arrow_upward,
                  color: const Color(0xFFFF7A5A),
                  label: 'Expenses',
                  amount: totalExpenses.abs(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String label,
    required double amount,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              CurrencyFormatter.format(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSectionSummary(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(double expenseAbs) {
    final budgetLimit = ref.watch(monthlyBudgetProvider);
    final budgetRatio = budgetLimit > 0 ? expenseAbs / budgetLimit : 0.0;
    final progressVal = budgetRatio.clamp(0.0, 1.0);

    Color getBudgetColor(double ratio) {
      if (ratio < 0.50) {
        return const Color(0xFF10B981);
      } else if (ratio <= 0.90) {
        return Colors.orange.shade600;
      } else {
        return const Color(0xFFFF7A5A);
      }
    }
    final Color budgetColor = getBudgetColor(budgetRatio);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${(budgetRatio * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: budgetColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressVal,
                minHeight: 10,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(budgetColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Spent: ${CurrencyFormatter.format(expenseAbs)} / ${CurrencyFormatter.format(budgetLimit)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(Transaction tx) {
    final cat = defaultCategories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => defaultCategories.first,
    );

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFFF7A5A),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (dir) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transaction?'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFFF7A5A)),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(transactionListProvider.notifier).delete(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: Color(0xFF1E293B),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              cat.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (tx.description != null && tx.description!.trim().isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tx.description!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else ...[
              const Spacer(),
            ],
            Text(
              tx.amount > 0
                  ? '+${CurrencyFormatter.format(tx.amount)}'
                  : CurrencyFormatter.format(tx.amount),
              style: TextStyle(
                color: tx.amount > 0 ? const Color(0xFF10B981) : const Color(0xFFFF7A5A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _section == ToshlSection.overview
                ? 'No transactions yet'
                : _section == ToshlSection.expenses
                    ? 'No expenses yet'
                    : _section == ToshlSection.incomes
                        ? 'No incomes yet'
                        : 'No transaction data yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the '+' button to record your first transaction.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
