import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:balanza/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../settings/providers/user_settings_provider.dart';
import '../../settings/providers/locale_provider.dart';
import '../../../core/utils/working_days_calculator.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction.dart';

class TimeBurnCalendarView extends ConsumerWidget {
  const TimeBurnCalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactionsAsync = ref.watch(transactionListProvider);
    final transactions = transactionsAsync.value ?? [];
    final locale = ref.watch(localeProvider);
    final isRo = locale.languageCode == 'ro';
    final l10n = AppLocalizations.of(context)!;

    // Monthly Math
    final totalMonthlyIncome = transactions
        .where((tx) => tx.amount > 0)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    final dailyHours = ref.watch(dailyWorkingHoursProvider).value ?? 8.0;
    final workingDays = WorkingDaysCalculator.getWorkingDaysInMonth(selectedMonth);
    final totalWorkingHours = workingDays * dailyHours;
    final hourlyWage = (totalMonthlyIncome > 0 && totalWorkingHours > 0)
        ? totalMonthlyIncome / totalWorkingHours
        : 0.0;
    final dailyWage = hourlyWage * dailyHours;

    final totalRegretSpent = transactions
        .where((tx) => tx.amount < 0 && tx.emotionalStatus == 'regret')
        .fold<double>(0.0, (sum, tx) => sum + tx.amount.abs());

    final regretDaysCount = (dailyWage > 0)
        ? (totalRegretSpent / dailyWage)
        : 0.0;
    final regretDaysStr = regretDaysCount.toStringAsFixed(1);

    // Days in Month Grid Setup
    final daysInMonthCount = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(selectedMonth.year, selectedMonth.month, 1).weekday; // 1 = Mon, 7 = Sun

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          l10n.timeBurnCalendar,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Regret Metric Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: totalRegretSpent > 0 ? const Color(0xFFFF7A5A) : const Color(0xFF334155),
                    width: totalRegretSpent > 0 ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_alt, color: Color(0xFFFF7A5A), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.regretDaysSummary(regretDaysStr),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRo
                          ? 'Regret Total: ${CurrencyFormatter.format(totalRegretSpent)} RON'
                          : 'Total Regret: ${CurrencyFormatter.format(totalRegretSpent)} RON',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF7A5A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Calendar Days Header (Mon-Sun)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: (isRo
                        ? ['Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm', 'Dum']
                        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
                    .map(
                      (d) => SizedBox(
                        width: 40,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),

              // Calendar Days Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.95,
                ),
                itemCount: (firstWeekday - 1) + daysInMonthCount,
                itemBuilder: (context, index) {
                  if (index < firstWeekday - 1) {
                    return const SizedBox.shrink();
                  }

                  final dayNum = index - (firstWeekday - 1) + 1;
                  final dayDate = DateTime(selectedMonth.year, selectedMonth.month, dayNum);

                  final dayTxs = transactions.where((tx) =>
                      tx.date.year == dayDate.year &&
                      tx.date.month == dayDate.month &&
                      tx.date.day == dayDate.day).toList();

                  final dayExpenses = dayTxs
                      .where((tx) => tx.amount < 0)
                      .fold<double>(0.0, (sum, tx) => sum + tx.amount.abs());

                  final dayRegret = dayTxs
                      .where((tx) => tx.amount < 0 && tx.emotionalStatus == 'regret')
                      .fold<double>(0.0, (sum, tx) => sum + tx.amount.abs());

                  final isBurned = dayExpenses > 0;
                  final isRegretDay = dailyWage > 0
                      ? (dayRegret > 0.5 * dailyWage)
                      : (dayRegret > 0 && dayRegret >= 0.5 * dayExpenses);

                  return GestureDetector(
                    onTap: () => _showDayDetailsSheet(context, dayDate, dayTxs, dayRegret, isRegretDay, isRo),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isRegretDay
                            ? const Color(0xFF7F1D1D) // Dark toxic red for regret
                            : isBurned
                                ? const Color(0xFF1E293B) // Muted burned card
                                : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRegretDay
                              ? const Color(0xFFFF7A5A)
                              : isBurned
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade900,
                          width: isRegretDay ? 2.0 : 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 6,
                            left: 8,
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isRegretDay ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                          if (isRegretDay) ...[
                            const Center(
                              child: Text(
                                '🤦',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                          ] else if (isBurned) ...[
                            const Center(
                              child: Text(
                                '🔥',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetailsSheet(
    BuildContext context,
    DateTime date,
    List<Transaction> txs,
    double regretTotal,
    bool isRegretDay,
    bool isRo,
  ) {
    final dateStr = DateFormat.yMMMMd().format(date);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isRegretDay) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF7A5A)),
                    ),
                    child: Text(
                      isRo
                          ? 'Ai muncit în această zi și ai regretat ${CurrencyFormatter.format(regretTotal)} RON. 🤦'
                          : 'You worked this day and regretted ${CurrencyFormatter.format(regretTotal)} RON. 🤦',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (txs.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      isRo ? 'Nicio tranzacție în această zi' : 'No transactions recorded on this day',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ] else ...[
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: txs.length,
                      itemBuilder: (context, idx) {
                        final tx = txs[idx];
                        final isExpense = tx.amount < 0;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            tx.description ?? (isExpense ? 'Expense' : 'Income'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            tx.emotionalStatus == 'regret'
                                ? 'Regret 🤦'
                                : tx.emotionalStatus == 'worth_it'
                                    ? 'Worth it 🔥'
                                    : 'Neutral',
                            style: TextStyle(
                              color: tx.emotionalStatus == 'regret'
                                  ? const Color(0xFFFF7A5A)
                                  : tx.emotionalStatus == 'worth_it'
                                      ? const Color(0xFF10B981)
                                      : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Text(
                            '${isExpense ? '-' : '+'}${CurrencyFormatter.format(tx.amount.abs())} RON',
                            style: TextStyle(
                              color: isExpense ? const Color(0xFFFF7A5A) : const Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
