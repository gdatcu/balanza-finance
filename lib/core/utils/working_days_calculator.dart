/// Utility to calculate exact working days (Monday-Friday) in a calendar month.
class WorkingDaysCalculator {
  /// Returns the number of weekdays (Monday to Friday) in the month of [date].
  static int getWorkingDaysInMonth(DateTime date) {
    final year = date.year;
    final month = date.month;
    final totalDaysInMonth = DateTime(year, month + 1, 0).day;

    int workingDays = 0;
    for (int day = 1; day <= totalDaysInMonth; day++) {
      final current = DateTime(year, month, day);
      if (current.weekday <= DateTime.friday) {
        workingDays++;
      }
    }
    return workingDays;
  }
}
