enum NetWorthType { asset, liability }

class NetWorthItem {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final NetWorthType type;
  final DateTime createdAt;

  const NetWorthItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.type,
    required this.createdAt,
  });

  factory NetWorthItem.fromJson(Map<String, dynamic> json) {
    return NetWorthItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      type: json['type'] == 'asset' ? NetWorthType.asset : NetWorthType.liability,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'balance': balance,
      'type': type == NetWorthType.asset ? 'asset' : 'liability',
      'created_at': createdAt.toIso8601String(),
    };
  }

  NetWorthItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? balance,
    NetWorthType? type,
    DateTime? createdAt,
  }) {
    return NetWorthItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
