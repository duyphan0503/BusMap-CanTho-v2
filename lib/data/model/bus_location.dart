import 'package:busmapcantho/core/utils/geo_utils.dart';

class BusLocation {
  final String vehicleId;
  final String routeId;
  final double lat;
  final double lng;
  final double speed;
  final double bearing;
  final String occupancyStatus;
  final DateTime timestamp;

  BusLocation({
    required this.vehicleId,
    required this.routeId,
    required this.lat,
    required this.lng,
    required this.speed,
    required this.bearing,
    required this.occupancyStatus,
    required this.timestamp,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    final raw = json['location'];
    double lat = 0, lng = 0;

    // Sử dụng GeoPoint để parse location
    final point = GeoPoint.fromGeography(raw);
    if (point != null) {
      lat = point.lat;
      lng = point.lng;
    }

    return BusLocation(
      vehicleId: json['vehicle_id'] as String,
      routeId: json['route_id'] as String,
      lat: lat,
      lng: lng,
      speed: (json['speed'] as num?)?.toDouble() ?? 0,
      bearing: (json['bearing'] as num?)?.toDouble() ?? 0,
      occupancyStatus: json['occupancy_status'] as String? ?? 'unknown',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'route_id': routeId,
      'location': 'SRID=4326;POINT($lng $lat)',
      'speed': speed,
      'bearing': bearing,
      'occupancy_status': occupancyStatus,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
