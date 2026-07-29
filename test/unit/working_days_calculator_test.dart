import 'package:flutter_test/flutter_test.dart';
import 'package:balanza/core/utils/working_days_calculator.dart';

void main() {
  group('WorkingDaysCalculator Unit Tests', () {
    test('Calculates weekdays in July 2026 (31 days, 23 weekdays)', () {
      final date = DateTime(2026, 7, 1);
      final days = WorkingDaysCalculator.getWorkingDaysInMonth(date);
      expect(days, equals(23));
    });

    test('Calculates weekdays in February 2025 (non-leap year, 28 days, 20 weekdays)', () {
      final date = DateTime(2025, 2, 1);
      final days = WorkingDaysCalculator.getWorkingDaysInMonth(date);
      expect(days, equals(20));
    });

    test('Calculates weekdays in February 2024 (leap year, 29 days, 21 weekdays)', () {
      final date = DateTime(2024, 2, 1);
      final days = WorkingDaysCalculator.getWorkingDaysInMonth(date);
      expect(days, equals(21));
    });

    test('Calculates weekdays in November 2026 (30 days, 21 weekdays)', () {
      final date = DateTime(2026, 11, 1);
      final days = WorkingDaysCalculator.getWorkingDaysInMonth(date);
      expect(days, equals(21));
    });
  });
}
