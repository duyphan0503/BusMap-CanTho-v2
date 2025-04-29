class UserFavorite {
  final String id;
  final String userId;
  final String? label;
  final String? stopId;
  final String? routeId;
  final DateTime createdAt;
  final String? type;

  UserFavorite({
    required this.id,
    required this.userId,
    this.label,
    this.stopId,
    this.routeId,
    required this.createdAt,
    this.type,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json) => UserFavorite(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    label: json['label'] as String?,
    stopId: json['stop_id'] as String?,
    routeId: json['route_id'] as String?,
    createdAt: DateTime.parse(json['created_at']),
    type: json['type'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'label': label,
    'stop_id': stopId,
    'route_id': routeId,
    'created_at': createdAt.toIso8601String(),
    'type': type,
  };
}