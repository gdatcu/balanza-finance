class WishlistItem {
  final String id;
  final String title;
  final double amount;
  final DateTime createdAt;
  final int coolingOffDays;
  final String status; // 'cooling_off', 'bought', 'discarded'

  const WishlistItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.coolingOffDays = 30,
    this.status = 'cooling_off',
  });

  /// Days remaining in cooling-off period
  int get daysRemaining {
    final now = DateTime.now();
    final elapsed = now.difference(createdAt).inDays;
    final remaining = coolingOffDays - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Wishlist Item',
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      coolingOffDays: json['cooling_off_days'] as int? ?? 30,
      status: json['status'] as String? ?? 'cooling_off',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'cooling_off_days': coolingOffDays,
      'status': status,
    };
  }

  WishlistItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? createdAt,
    int? coolingOffDays,
    String? status,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      coolingOffDays: coolingOffDays ?? this.coolingOffDays,
      status: status ?? this.status,
    );
  }
}
