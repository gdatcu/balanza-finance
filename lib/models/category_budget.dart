class CategoryBudget {
  final String id;
  final String userId;
  final String category;
  final double amountLimit;
  final DateTime? createdAt;

  const CategoryBudget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amountLimit,
    this.createdAt,
  });

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      category: json['category'] as String? ?? json['category_name'] as String? ?? '',
      amountLimit: (json['amount_limit'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'amount_limit': amountLimit,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  CategoryBudget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amountLimit,
    DateTime? createdAt,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amountLimit: amountLimit ?? this.amountLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
