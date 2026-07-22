class Account {
  final String id;
  final String name;
  final double balance;
  final String userId;
  final DateTime createdAt;

  const Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.userId,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    double? balance,
    String? userId,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
