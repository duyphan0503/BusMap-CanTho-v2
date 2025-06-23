import 'package:busmapcantho/core/utils/geo_utils.dart';

class BusStop {
  final String id;
  final String? stopCode;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distanceMeters;

  BusStop({
    required this.id,
    this.stopCode,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.distanceMeters,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    final geoPoint = GeoPoint.fromGeography(json['location']);

    final lat = geoPoint?.lat ?? (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = geoPoint?.lng ?? (json['longitude'] as num?)?.toDouble() ?? 0.0;

    return BusStop(
      id: json['id'] as String,
      stopCode: json['stop_code'] as String?,
      name: json['name'] as String? ?? 'Unknown',
      latitude: lat,
      longitude: lng,
      address: json['address'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now(),
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stop_code': stopCode,
    'name': name,
    'location':
        'SRID=4326;POINT($longitude $latitude)', // WKT format for PostGIS
    'address': address,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }
}
