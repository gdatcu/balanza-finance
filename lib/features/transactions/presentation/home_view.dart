import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../../../models/transaction.dart';
import '../../../models/category_summary.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/category_localizer.dart';
import 'transaction_input_sheet.dart';
import 'categories_data.dart';
import '../../analytics/presentation/expense_pie_chart.dart';
import '../../analytics/presentation/wealth_advisor_banner.dart';
import '../../analytics/presentation/wealth_advisor_card.dart';
import '../../analytics/providers/wealth_advisor_provider.dart';
import '../../settings/presentation/settings_view.dart';
import '../../settings/providers/locale_provider.dart';
import '../../settings/providers/updater_provider.dart';
import '../../net_worth/presentation/net_worth_view.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updaterProvider).checkForUpdates(context);
    });
  }

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

  String _formatDateHeader(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final compareDate = DateTime(date.year, date.month, date.day);

    if (compareDate == today) {
      return AppLocalizations.of(context)!.today;
    } else if (compareDate == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      final currentLocale = Localizations.localeOf(context).languageCode;
      final rawFormatted = DateFormat.yMMMEd(currentLocale).format(date);
      return rawFormatted.isNotEmpty
          ? rawFormatted[0].toUpperCase() + rawFormatted.substring(1)
          : rawFormatted;
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
          title: Text(
            AppLocalizations.of(context)!.appTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.byDate.toUpperCase()),
                  Tab(text: AppLocalizations.of(context)!.byCategory.toUpperCase()),
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
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: const TextStyle(
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
                  title: Text(AppLocalizations.of(context)!.overview, style: const TextStyle(color: Colors.white)),
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
                  title: Text(AppLocalizations.of(context)!.expenses, style: const TextStyle(color: Color(0xFFFF7A5A))),
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
                  title: Text(AppLocalizations.of(context)!.income, style: const TextStyle(color: Color(0xFF10B981))),
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
                  title: Text(AppLocalizations.of(context)!.budgets, style: const TextStyle(color: Color(0xFFF59E0B))),
                  selected: _section == ToshlSection.budgets,
                  selectedTileColor: const Color(0xFFF59E0B).withValues(alpha: 0.05),
                  onTap: () {
                    setState(() {
                      _section = ToshlSection.budgets;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance, color: Color(0xFFF59E0B)),
                  title: Text(AppLocalizations.of(context)!.netWorth, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const NetWorthView()),
                    );
                  },
                ),
                const Divider(color: Colors.white12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.settings.toUpperCase(),
                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.grey),
                  title: Text(AppLocalizations.of(context)!.settings, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsView()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.grey),
                  title: Text(AppLocalizations.of(context)!.language, style: const TextStyle(color: Colors.white)),
                  trailing: Consumer(
                    builder: (context, ref, _) {
                      final currentLocale = ref.watch(localeProvider);
                      final isRo = currentLocale.languageCode == 'ro';
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => ref.read(localeProvider.notifier).setLocale('en'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                'EN',
                                style: TextStyle(
                                  color: !isRo ? const Color(0xFFFF7A5A) : Colors.grey,
                                  fontWeight: !isRo ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const Text('|', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          GestureDetector(
                            onTap: () => ref.read(localeProvider.notifier).setLocale('ro'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                'RO',
                                style: TextStyle(
                                  color: isRo ? const Color(0xFFFF7A5A) : Colors.grey,
                                  fontWeight: isRo ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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
    final advisorState = ref.watch(wealthAdvisorProvider);
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
          if (advisorState != null) WealthAdvisorCard(state: advisorState),
          _buildAdvisorWidget(context),
          const SizedBox(height: 16),
          _buildOverviewCard(totalBalance, totalIncome, totalExpenses),
          const SizedBox(height: 16),
          _buildBudgetCard(totalExpenses.abs()),
          const SizedBox(height: 16),
        ] else if (_section == ToshlSection.expenses) ...[
          _buildSectionSummary(AppLocalizations.of(context)!.totalExpenses, totalExpenses.abs(), const Color(0xFFFF7A5A)),
          const SizedBox(height: 16),
        ] else if (_section == ToshlSection.incomes) ...[
          _buildSectionSummary(AppLocalizations.of(context)!.totalIncome, totalIncome, const Color(0xFF10B981)),
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
                  _formatDateHeader(context, date),
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    AppLocalizations.of(context)!.noCategoryTransactions,
                    style: const TextStyle(color: Colors.grey),
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
                    CategoryLocalizer.getLocalizedName(context, item.categoryName),
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
    final currentLocale = Localizations.localeOf(context).languageCode;
    final rawMonthText = DateFormat.yMMMM(currentLocale).format(selectedMonth);
    final monthText = rawMonthText.isNotEmpty
        ? rawMonthText[0].toUpperCase() + rawMonthText.substring(1)
        : rawMonthText;

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

  Widget _buildAdvisorWidget(BuildContext context) {
    final quote = ref.watch(insightsProvider);
    final isRo = quote.contains(' De ce contează: ');
    final splitter = isRo ? ' De ce contează: ' : ' Why it matters: ';
    final parts = quote.split(splitter);
    final primaryText = parts[0];
    final whyItMattersText = parts.length > 1 
        ? (isRo ? 'De ce contează: ${parts[1]}' : 'Why it matters: ${parts[1]}')
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: Color(0xFFF59E0B),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.financialInsight.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    primaryText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  if (whyItMattersText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      whyItMattersText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
            Text(
              AppLocalizations.of(context)!.totalBalance,
              style: const TextStyle(
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
                  label: AppLocalizations.of(context)!.income,
                  amount: totalIncome,
                ),
                _buildSummaryItem(
                  icon: Icons.arrow_upward,
                  color: const Color(0xFFFF7A5A),
                  label: AppLocalizations.of(context)!.expenses,
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
                Text(
                  AppLocalizations.of(context)!.monthlyBudget,
                  style: const TextStyle(
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
              '${AppLocalizations.of(context)!.spent}: ${CurrencyFormatter.format(expenseAbs)} / ${CurrencyFormatter.format(budgetLimit)}',
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
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteTransactionTitle),
            content: Text(
              AppLocalizations.of(context)!.confirmDeleteTransaction,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: const TextStyle(color: Color(0xFFFF7A5A)),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(transactionListProvider.notifier).delete(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.transactionDeleted),
            backgroundColor: const Color(0xFF1E293B),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              CategoryLocalizer.getLocalizedName(context, cat.name),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                if (tx.originalCurrency == 'EUR' && tx.originalAmount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.originalAmount! > 0
                        ? '+€${tx.originalAmount!.toStringAsFixed(2)}'
                        : '-€${tx.originalAmount!.abs().toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
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
                ? AppLocalizations.of(context)!.noTransactionsYet
                : _section == ToshlSection.expenses
                    ? AppLocalizations.of(context)!.noExpensesYet
                    : _section == ToshlSection.incomes
                        ? AppLocalizations.of(context)!.noIncomesYet
                        : AppLocalizations.of(context)!.noTransactionDataYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapToRecordFirstTransaction,
            style: const TextStyle(
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
