import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/utils/working_days_calculator.dart';
import 'user_settings_provider.dart';

/// Calculation result model for Time Cost
class TimeCostResult {
  final double amount;
  final double monthlyIncome;
  final int workingDaysInMonth;
  final double dailyWorkingHours;
  final double totalWorkingHours;
  final double hourlyWage;
  final double timeCostHours;

  const TimeCostResult({
    required this.amount,
    required this.monthlyIncome,
    required this.workingDaysInMonth,
    required this.dailyWorkingHours,
    required this.totalWorkingHours,
    required this.hourlyWage,
    required this.timeCostHours,
  });

  /// Formatted duration string e.g. "3h 45m" or "2d 4h"
  String formatDuration({bool isRomanian = false}) {
    if (timeCostHours <= 0) return '0h';

    final totalMinutes = (timeCostHours * 60).round();
    final days = (timeCostHours / dailyWorkingHours).floor();
    final hours = (timeCostHours % dailyWorkingHours).floor();
    final minutes = totalMinutes % 60;

    final parts = <String>[];
    if (days > 0) {
      final daySuffix = isRomanian ? 'z' : 'd';
      parts.add('$days$daySuffix');
    }
    if (hours > 0 || (days == 0 && minutes > 0)) {
      parts.add('${hours}h');
    }
    if (minutes > 0 && days == 0) {
      parts.add('${minutes}m');
    }

    return parts.isEmpty ? '0h' : parts.join(' ');
  }
}

/// Params for timeCostProvider family
class TimeCostParams {
  final DateTime month;
  final double amount;

  const TimeCostParams({
    required this.month,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeCostParams &&
          runtimeType == other.runtimeType &&
          month.year == other.month.year &&
          month.month == other.month.month &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(month.year, month.month, amount);
}

/// Provider to calculate the exact time-cost of an amount in working hours/days based on monthly income and working days.
final timeCostProvider = Provider.family<TimeCostResult?, TimeCostParams>((ref, params) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final transactions = transactionsAsync.value ?? [];

  // 1. Calculate total monthly income (sum of income transactions)
  final totalMonthlyIncome = transactions
      .where((tx) => tx.amount > 0)
      .fold<double>(0.0, (sum, tx) => sum + tx.amount);

  // 2. Fetch daily working hours (default 8.0)
  final dailyWorkingHours = ref.watch(dailyWorkingHoursProvider).value ?? 8.0;

  // 3. Calculate working days in the given month using WorkingDaysCalculator helper
  final workingDaysInMonth = WorkingDaysCalculator.getWorkingDaysInMonth(params.month);

  // 4. Calculate total working hours in the month
  final totalWorkingHours = workingDaysInMonth * dailyWorkingHours;

  // 5. Fail gracefully if 0 logged income or 0 working hours
  if (totalMonthlyIncome <= 0 || totalWorkingHours <= 0) {
    return null;
  }

  // 6. Calculate hourly wage and time cost hours
  final hourlyWage = totalMonthlyIncome / totalWorkingHours;
  if (hourlyWage <= 0) return null;

  final timeCostHours = params.amount.abs() / hourlyWage;

  return TimeCostResult(
    amount: params.amount,
    monthlyIncome: totalMonthlyIncome,
    workingDaysInMonth: workingDaysInMonth,
    dailyWorkingHours: dailyWorkingHours,
    totalWorkingHours: totalWorkingHours,
    hourlyWage: hourlyWage,
    timeCostHours: timeCostHours,
  );
});
