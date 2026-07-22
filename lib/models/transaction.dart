class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final String? categoryId;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    this.categoryId,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      categoryId: json['category_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
