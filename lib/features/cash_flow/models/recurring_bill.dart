class RecurringBill {
  final String id;
  final String title;
  final double amount; // negative for bills/expenses, positive for income
  final String categoryId;
  final String? subcategoryId;
  final int dueDay; // 1-31
  final bool isIncome;
  final bool isAutoDetected;
  final bool isPaidThisMonth;
  final DateTime? lastPaidDate;
  final DateTime createdAt;

  const RecurringBill({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    this.subcategoryId,
    required this.dueDay,
    required this.isIncome,
    this.isAutoDetected = false,
    this.isPaidThisMonth = false,
    this.lastPaidDate,
    required this.createdAt,
  });

  RecurringBill copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    String? subcategoryId,
    int? dueDay,
    bool? isIncome,
    bool? isAutoDetected,
    bool? isPaidThisMonth,
    DateTime? lastPaidDate,
    DateTime? createdAt,
  }) {
    return RecurringBill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      dueDay: dueDay ?? this.dueDay,
      isIncome: isIncome ?? this.isIncome,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      isPaidThisMonth: isPaidThisMonth ?? this.isPaidThisMonth,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory RecurringBill.fromJson(Map<String, dynamic> json) {
    return RecurringBill(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as String,
      subcategoryId: json['subcategory_id'] as String?,
      dueDay: json['due_day'] as int? ?? 1,
      isIncome: json['is_income'] as bool? ?? false,
      isAutoDetected: json['is_auto_detected'] as bool? ?? false,
      isPaidThisMonth: json['is_paid_this_month'] as bool? ?? false,
      lastPaidDate: json['last_paid_date'] != null ? DateTime.parse(json['last_paid_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'due_day': dueDay,
      'is_income': isIncome,
      'is_auto_detected': isAutoDetected,
      'is_paid_this_month': isPaidThisMonth,
      'last_paid_date': lastPaidDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
