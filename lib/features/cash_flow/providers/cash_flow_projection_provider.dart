import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurring_bill.dart';
import 'recurring_bills_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class CashFlowDailyPoint {
  final DateTime date;
  final double balance;
  final bool isProjected;
  final List<String> billNames;
  final double safeToSpend;

  const CashFlowDailyPoint({
    required this.date,
    required this.balance,
    required this.isProjected,
    required this.billNames,
    required this.safeToSpend,
  });
}

class CashFlowSummary {
  final double safeToSpendToday;
  final double currentBalance;
  final double projectedMonthEndBalance;
  final double totalUnpaidBills;
  final double totalUnpaidIncome;
  final List<CashFlowDailyPoint> dailyPoints;
  final List<RecurringBill> upcomingUnpaidBills;

  const CashFlowSummary({
    required this.safeToSpendToday,
    required this.currentBalance,
    required this.projectedMonthEndBalance,
    required this.totalUnpaidBills,
    required this.totalUnpaidIncome,
    required this.dailyPoints,
    required this.upcomingUnpaidBills,
  });
}

final cashFlowProjectionProvider = Provider<CashFlowSummary>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final transactions = transactionsAsync.value ?? [];
  final bills = ref.watch(recurringBillsProvider);

  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

  // Calculate current total balance from all logged transactions
  double currentBalance = transactions.fold(0.0, (sum, t) => sum + t.amount);

  // Unpaid bills and income for remainder of month
  final unpaidBills = bills.where((b) => !b.isPaidThisMonth && !b.isIncome).toList();
  final unpaidIncome = bills.where((b) => !b.isPaidThisMonth && b.isIncome).toList();

  final totalUnpaidBills = unpaidBills.fold(0.0, (sum, b) => sum + b.amount.abs());
  final totalUnpaidIncome = unpaidIncome.fold(0.0, (sum, b) => sum + b.amount.abs());

  // Safe to spend today = Current Balance - Unpaid Due Bills before next income or month end
  final safeToSpendToday = (currentBalance - totalUnpaidBills).clamp(0.0, double.infinity);

  // Build daily cash flow projection points for current month (1..daysInMonth)
  final dailyPoints = <CashFlowDailyPoint>[];
  double runningBalance = 0.0;

  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(now.year, now.month, day);
    final isProjected = day > now.day;

    final dayBills = bills.where((b) => b.dueDay == day).toList();
    final dayBillNames = dayBills.map((b) => b.title).toList();

    if (!isProjected) {
      // Calculate actual balance at end of 'day'
      final dayTxSum = transactions
          .where((t) => t.date.year == now.year && t.date.month == now.month && t.date.day <= day)
          .fold(0.0, (sum, t) => sum + t.amount);
      runningBalance = dayTxSum;
    } else {
      // Projected balance: add/subtract scheduled bills on this day
      for (final b in dayBills) {
        if (!b.isPaidThisMonth) {
          runningBalance += b.amount;
        }
      }
    }

    final daySafeToSpend = (runningBalance - totalUnpaidBills).clamp(0.0, double.infinity);

    dailyPoints.add(
      CashFlowDailyPoint(
        date: date,
        balance: runningBalance,
        isProjected: isProjected,
        billNames: dayBillNames,
        safeToSpend: daySafeToSpend,
      ),
    );
  }

  final projectedMonthEndBalance = dailyPoints.isNotEmpty ? dailyPoints.last.balance : currentBalance;

  // Upcoming unpaid bills sorted by due day
  final List<RecurringBill> sortedUpcomingUnpaid = [...unpaidBills]..sort((a, b) => a.dueDay.compareTo(b.dueDay));

  return CashFlowSummary(
    safeToSpendToday: safeToSpendToday,
    currentBalance: currentBalance,
    projectedMonthEndBalance: projectedMonthEndBalance,
    totalUnpaidBills: totalUnpaidBills,
    totalUnpaidIncome: totalUnpaidIncome,
    dailyPoints: dailyPoints,
    upcomingUnpaidBills: sortedUpcomingUnpaid,
  );
});
