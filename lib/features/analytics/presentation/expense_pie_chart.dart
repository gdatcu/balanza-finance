import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/presentation/categories_data.dart';
import '../../../models/transaction.dart';
import '../../../core/utils/currency_formatter.dart';

class ExpensePieChart extends ConsumerWidget {
  final List<Transaction>? customTransactions;
  final bool isIncome;

  const ExpensePieChart({
    super.key,
    this.customTransactions,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (customTransactions != null) {
      return _buildChart(context, customTransactions!);
    }

    final transactionsAsync = ref.watch(transactionListProvider);

    return transactionsAsync.when(
      data: (transactions) => _buildChart(context, transactions),
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildChart(BuildContext context, List<Transaction> transactions) {
    double totalAmount = 0.0;
    final Map<String, double> groupedAmount = {};

    for (final tx in transactions) {
      final matchesFilter = isIncome ? tx.amount > 0 : tx.amount < 0;
      if (matchesFilter) {
        final amt = tx.amount.abs();
        totalAmount += amt;
        final catId = tx.categoryId ?? '';
        groupedAmount[catId] = (groupedAmount[catId] ?? 0.0) + amt;
      }
    }

    if (totalAmount == 0) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              isIncome
                  ? 'No income data to display yet.'
                  : 'No expense data to display yet.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      );
    }

    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];

    groupedAmount.forEach((catId, sum) {
      final cat = defaultCategories.firstWhere(
        (c) => c.id == catId,
        orElse: () => defaultCategories.first,
      );
      final color = getCategoryColor(cat.color);
      final percentage = (sum / totalAmount) * 100;
      final showTitleText = percentage > 5.0;

      sections.add(
        PieChartSectionData(
          value: sum,
          title: showTitleText ? '${cat.name}\n${percentage.toStringAsFixed(1)}%' : '',
          color: color,
          radius: 65,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      );

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${CurrencyFormatter.format(sum)} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                isIncome ? 'Income by Category' : 'Expenses by Category',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 35,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            Column(
              children: legendItems,
            ),
          ],
        ),
      ),
    );
  }
}
