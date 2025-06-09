import 'dart:typed_data';

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

    // Handle GeoJSON object or WKT string
    if (raw is Map && raw['type'] == 'Point' && raw['coordinates'] is List) {
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
        final x = data.getFloat64(offset, bo);
        final y = data.getFloat64(offset + 8, bo);
        lng = x;
        lat = y;
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
