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
}

class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? userId;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.userId,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      userId: json['user_id'] as String?,
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? userId,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
