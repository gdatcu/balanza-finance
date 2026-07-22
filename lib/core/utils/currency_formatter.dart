class CurrencyFormatter {
  static String format(double amount) {
    final isNegative = amount < 0;
    final absAmt = amount.abs().toStringAsFixed(2);
    return '${isNegative ? '-' : ''}RON $absAmt';
  }
}
