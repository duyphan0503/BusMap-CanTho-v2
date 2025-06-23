import 'dart:typed_data';

/// Converts a geographic point from various formats (GeoJSON, WKB hex, WKT) to lat/lng coordinates
class GeoPoint {
  final double lat;
  final double lng;

  const GeoPoint(this.lat, this.lng);

  /// Parse a geographic point from various formats
  static GeoPoint? fromGeography(dynamic raw) {
    if (raw == null) return null;

    double lat = 0, lng = 0;
    bool success = false;

    // Handle GeoJSON object
    if (raw is Map && raw['type'] == 'Point' && raw['coordinates'] is List) {
      final coords = raw['coordinates'] as List;
      if (coords.length == 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
        success = true;
      }
    }
    // Handle string formats (WKB hex or WKT)
    else if (raw is String) {
      final s = raw.trim();

      // WKB Hex string (EWKB) case
      if (RegExp(r'^[0-9A-Fa-f]+$').hasMatch(s)) {
        try {
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
          success = true;
        } catch (e) {
          // If parsing fails, success remains false
        }
      }
      // WKT format
      else {
        final match = RegExp(
          r'POINT\(\s*([\d.-]+)\s+([\d.-]+)\s*\)',
        ).firstMatch(s);

        if (match != null) {
          lng = double.tryParse(match.group(1)!) ?? 0;
          lat = double.tryParse(match.group(2)!) ?? 0;
          success = true;
        }
      }
    }

    return success ? GeoPoint(lat, lng) : null;
  }

  @override
  String toString() => 'GeoPoint($lat, $lng)';
}

void main() {
  const ewkbHex = '0101000020E6100000FF03AC553B6F5A400B30E2F1A3082440';

  final point = GeoPoint.fromGeography(ewkbHex);

  if (point != null) {
    print('Giải mã thành công: $point');
  } else {
    print('Giải mã thất bại.');
  }
}
