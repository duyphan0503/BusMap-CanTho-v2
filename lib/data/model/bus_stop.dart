import 'dart:typed_data';

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
    double lat = 0.0;
    double lng = 0.0;
    final raw = json['location'];

    // Parse location field similar to bus_location.dart
    if (raw is Map && raw['type'] == 'Point' && raw['coordinates'] is List) {
      // Handle GeoJSON object
      final coords = raw['coordinates'] as List;
      if (coords.length == 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    } else if (raw is String) {
      final s = raw.trim();
      // WKB Hex string (EWKB) case
      if (RegExp(r'^[0-9A-Fa-f]+$').hasMatch(s)) {
        // Decode hex to bytes
        final bytes = <int>[];
        for (var i = 0; i < s.length; i += 2) {
          bytes.add(int.parse(s.substring(i, i + 2), radix: 16));
        }
        final data = ByteData.sublistView(Uint8List.fromList(bytes));
        // Determine byte order
        final bo = bytes[0] == 0 ? Endian.big : Endian.little;
        // Read type and check SRID flag
        final type = data.getUint32(1, bo);
        // EWKB SRID flag is 0x20000000
        final hasSrid = (type & 0x20000000) != 0;
        var offset = 1 + 4;
        if (hasSrid) offset += 4;
        // Read coordinates
        lng = data.getFloat64(offset, bo);
        lat = data.getFloat64(offset + 8, bo);
      } else {
        // WKT format, e.g. "SRID=4326;POINT(lng lat)" or "POINT(lng lat)"
        final match = RegExp(
          r'POINT\(\s*([\d\.-]+)\s+([\d\.-]+)\s*\)',
        ).firstMatch(s);
        if (match != null) {
          lng = double.tryParse(match.group(1)!) ?? 0;
          lat = double.tryParse(match.group(2)!) ?? 0;
        }
      }
    } else {
      // Fallback for direct lat/lng fields if present
      lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    }

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
}
