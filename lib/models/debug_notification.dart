class DebugNotification {
  final String id;
  final String packageName;
  final String rawTitle;
  final String rawBody;
  final DateTime createdAt;

  const DebugNotification({
    required this.id,
    required this.packageName,
    required this.rawTitle,
    required this.rawBody,
    required this.createdAt,
  });

  factory DebugNotification.fromJson(Map<String, dynamic> json) {
    return DebugNotification(
      id: json['id'] as String,
      packageName: json['package_name'] as String,
      rawTitle: json['raw_title'] as String? ?? '',
      rawBody: json['raw_body'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_name': packageName,
      'raw_title': rawTitle,
      'raw_body': rawBody,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
