class UserFavorite {
  final String id;
  final String userId;
  final String? label;
  final String? stopId;
  final String? routeId;
  final String? type;
  final DateTime createdAt;
  final String? placeId;
  final String? placeName;
  final double? latitude;
  final double? longitude;

  UserFavorite({
    required this.id,
    required this.userId,
    this.label,
    this.stopId,
    this.routeId,
    this.type,
    required this.createdAt,
    this.placeId,
    this.placeName,
    this.latitude,
    this.longitude,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json) => UserFavorite(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    label: json['label'] as String?,
    stopId: json['stop_id'] as String?,
    routeId: json['route_id'] as String?,
    type: json['type'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    placeId: json['place_id'] as String?,
    placeName: json['place_name'] as String?,
    latitude: json['latitude'] as double?,
    longitude: json['longitude'] as double?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'label': label,
    'stop_id': stopId,
    'route_id': routeId,
    'type': type,
    'created_at': createdAt.toIso8601String(),
    'place_id': placeId,
    'place_name': placeName,
    'latitude': latitude,
    'longitude': longitude,
  };
}
