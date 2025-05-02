class BusLocation {
  final String vehicleId;
  final String? routeId;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? bearing;
  final DateTime timestamp;
  final String? occupancyStatus;
  final DateTime updatedAt;

  BusLocation({
    required this.vehicleId,
    this.routeId,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.bearing,
    required this.timestamp,
    this.occupancyStatus,
    required this.updatedAt,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    // Supabase trả về geography(Point) dưới dạng GeoJSON:
    final loc = json['location'] as Map<String, dynamic>;
    final coords = loc['coordinates'] as List;
    return BusLocation(
      vehicleId: json['vehicle_id'] as String,
      routeId: json['route_id'] as String?,
      longitude: (coords[0] as num).toDouble(),
      latitude: (coords[1] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      bearing:
      json['bearing'] != null ? (json['bearing'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      occupancyStatus: json['occupancy_status'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'vehicle_id': vehicleId,
    'route_id': routeId,
    'location': {
      'type': 'Point',
      'coordinates': [longitude, latitude],
    },
    'speed': speed,
    'bearing': bearing,
    'timestamp': timestamp.toIso8601String(),
    'occupancy_status': occupancyStatus,
    'updated_at': updatedAt.toIso8601String(),
  };
}
