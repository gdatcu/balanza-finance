import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balanza/models/transaction.dart';
import 'package:balanza/features/transactions/providers/transaction_provider.dart';
import 'package:balanza/features/settings/providers/user_settings_provider.dart';
import 'package:balanza/features/settings/providers/time_cost_provider.dart';
import 'package:balanza/core/utils/working_days_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimeCostProvider Unit Tests', () {
    test('Calculates exact working days in July 2026 (23 days)', () {
      final july2026 = DateTime(2026, 7, 1);
      final days = WorkingDaysCalculator.getWorkingDaysInMonth(july2026);
      expect(days, 23);
    });

    test('Returns null when user has 0 logged income', () {
      SharedPreferences.setMockInitialValues({});

      final july2026 = DateTime(2026, 7, 1);
      final container = ProviderContainer(
        overrides: [
          transactionListProvider.overrideWithValue(const AsyncValue.data([])),
          dailyWorkingHoursProvider.overrideWithValue(const AsyncValue.data(8.0)),
        ],
      );

      final result = container.read(
        timeCostProvider(TimeCostParams(month: july2026, amount: 200.0)),
      );

      expect(result, isNull);
    });

    test('Calculates correct hourly wage and time cost for 23 working days', () {
      final july2026 = DateTime(2026, 7, 1);
      final incomeTx = Transaction(
        id: 'tx-1',
        userId: 'u1',
        accountId: 'a1',
        amount: 9200.0, // 9,200 RON income
        date: july2026,
        createdAt: july2026,
      );

      // 23 working days * 8 hours/day = 184 working hours
      // Hourly wage = 9200 / 184 = 50 RON/hour
      // Expense = 200 RON => 4 hours (200 / 50)
      final container = ProviderContainer(
        overrides: [
          transactionListProvider.overrideWithValue(AsyncValue.data([incomeTx])),
          dailyWorkingHoursProvider.overrideWithValue(const AsyncValue.data(8.0)),
        ],
      );

      final result = container.read(
        timeCostProvider(TimeCostParams(month: july2026, amount: 200.0)),
      );

      expect(result, isNotNull);
      expect(result!.workingDaysInMonth, 23);
      expect(result.dailyWorkingHours, 8.0);
      expect(result.totalWorkingHours, 184.0);
      expect(result.hourlyWage, 50.0);
      expect(result.timeCostHours, 4.0);
      expect(result.formatDuration(), '4h');
    });
  });
}
