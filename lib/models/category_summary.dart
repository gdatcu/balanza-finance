enum TransactionType { income, expense }

class CategorySummary {
  final String categoryName;
  final double totalAmount;
  final TransactionType transactionType;

  const CategorySummary({
    required this.categoryName,
    required this.totalAmount,
    required this.transactionType,
  });
}
