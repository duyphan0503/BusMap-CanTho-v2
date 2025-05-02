class UserFavorite {
  final String id;
  final String userId;
  final String? label;
  final String? stopId;
  final String? type;
  final DateTime createdAt;

  UserFavorite({
    required this.id,
    required this.userId,
    this.label,
    this.stopId,
    this.type,
    required this.createdAt,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json) =>
      UserFavorite(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        label: json['label'] as String?,
        stopId: json['stop_id'] as String?,
        type: json['type'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'label': label,
    'stop_id': stopId,
    'type': type,
    'created_at': createdAt.toIso8601String(),
  };
}
