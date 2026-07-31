class CurrencyFormatter {
  static String format(double amount) {
    final isNegative = amount < 0;
    final absAmt = amount.abs().toStringAsFixed(2);
    return '${isNegative ? '-' : ''}RON $absAmt';
  }

  static String formatCompact(double amount) {
    final isNegative = amount < 0;
    final abs = amount.abs();
    final prefix = isNegative ? '-' : '';
    if (abs >= 1000000) {
      return '$prefix${(abs / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      return '$prefix${(abs / 1000).toStringAsFixed(1)}k';
    } else {
      return '$prefix${abs.toStringAsFixed(0)}';
    }
  }
}
