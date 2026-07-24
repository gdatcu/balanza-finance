enum CategoryType {
  food,
  transport,
  rent,
  utilities,
  salary,
  entertainment,
  shopping,
  investments,
  gifts,
  // ignore: constant_identifier_names
  coffee_tea,
  restaurants,
  // ignore: constant_identifier_names
  pet_care,
  subscriptions,
  other,
  // ignore: constant_identifier_names
  credit_installments,
  groceries,
  // ignore: constant_identifier_names
  meal_tickets,
  // ignore: constant_identifier_names
  side_hustle,
}

class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? userId;
  final bool isIncome;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.userId,
    this.isIncome = false,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      userId: json['user_id'] as String?,
      isIncome: json['is_income'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'user_id': userId,
      'is_income': isIncome,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? userId,
    bool? isIncome,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      isIncome: isIncome ?? this.isIncome,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
