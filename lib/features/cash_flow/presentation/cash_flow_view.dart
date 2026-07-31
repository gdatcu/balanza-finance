import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/recurring_bill.dart';
import '../providers/cash_flow_projection_provider.dart';
import '../providers/recurring_bills_provider.dart';
import 'widgets/cash_flow_projection_chart.dart';
import 'widgets/recurring_bill_input_sheet.dart';

class CashFlowView extends ConsumerWidget {
  const CashFlowView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(cashFlowProjectionProvider);
    final bills = ref.watch(recurringBillsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.insights, color: Color(0xFF3B82F6), size: 22),
            SizedBox(width: 8),
            Text('Cash Flow & Bill Forecast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
        onPressed: () => RecurringBillInputSheet.show(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Summary Metric Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Safe-to-Spend Today',
                    value: CurrencyFormatter.format(summary.safeToSpendToday),
                    icon: Icons.shield_outlined,
                    color: const Color(0xFF10B981),
                    subtitle: 'After unpaid bills',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Month-End Balance',
                    value: CurrencyFormatter.format(summary.projectedMonthEndBalance),
                    icon: Icons.auto_graph,
                    color: const Color(0xFF3B82F6),
                    subtitle: 'Projected forecast',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Unpaid Bills',
                    value: CurrencyFormatter.format(summary.totalUnpaidBills),
                    icon: Icons.schedule,
                    color: const Color(0xFFEF4444),
                    subtitle: '${summary.upcomingUnpaidBills.length} pending items',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Expected Income',
                    value: CurrencyFormatter.format(summary.totalUnpaidIncome),
                    icon: Icons.south_west,
                    color: const Color(0xFF10B981),
                    subtitle: 'Pending salary/grants',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Predictive Cash Flow Chart
            CashFlowProjectionChart(summary: summary),
            const SizedBox(height: 20),

            // 3. Upcoming Bills List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recurring Bills & Income Calendar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${bills.length} Items',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4. Bills List
            if (bills.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text('No recurring bills set. Tap "+ Add Bill" to start tracking.', style: TextStyle(color: Colors.white54)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bills.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return _buildBillRow(context, ref, bill);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBillRow(BuildContext context, WidgetRef ref, RecurringBill bill) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: bill.isPaidThisMonth ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Due day badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bill.isIncome
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('DAY', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                Text(
                  '${bill.dueDay}',
                  style: TextStyle(
                    color: bill.isIncome ? const Color(0xFF10B981) : const Color(0xFF60A5FA),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Title & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.title,
                  style: TextStyle(
                    color: bill.isPaidThisMonth ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: bill.isPaidThisMonth ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: bill.isPaidThisMonth
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bill.isPaidThisMonth ? '✓ Paid This Month' : '⏳ Due Day ${bill.dueDay}',
                        style: TextStyle(
                          color: bill.isPaidThisMonth ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Text(
            CurrencyFormatter.format(bill.amount),
            style: TextStyle(
              color: bill.amount < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),

          // Paid Switch
          Switch(
            value: bill.isPaidThisMonth,
            activeColor: const Color(0xFF10B981),
            onChanged: (_) {
              ref.read(recurringBillsProvider.notifier).togglePaidThisMonth(bill.id);
            },
          ),

          // Popup Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 18),
            color: const Color(0xFF1E293B),
            onSelected: (val) {
              if (val == 'edit') {
                RecurringBillInputSheet.show(context, existingBill: bill);
              } else if (val == 'delete') {
                ref.read(recurringBillsProvider.notifier).deleteBill(bill.id);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit Bill', style: TextStyle(color: Colors.white, fontSize: 13))),
              PopupMenuItem(value: 'delete', child: Text('Delete Bill', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }
}
