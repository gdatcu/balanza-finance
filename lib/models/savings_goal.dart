class SavingsGoal {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String icon;
  final String color;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.icon = 'savings',
    this.color = '#10B981',
    required this.createdAt,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return ((currentAmount / targetAmount) * 100).clamp(0.0, 100.0);
  }

  bool get isCompleted => currentAmount >= targetAmount;

  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date'] as String) : null,
      icon: json['icon'] as String? ?? 'savings',
      color: json['color'] as String? ?? '#10B981',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8601String(),
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
