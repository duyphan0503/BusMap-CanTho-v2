import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

/// Service class to interact with OSRM (Open Source Routing Machine) API
///
/// Provides methods to fetch route geometries between multiple points following
/// actual road networks rather than straight lines.
@lazySingleton
class OsrmRoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org';
  final Logger _logger;

  OsrmRoutingService(this._logger);

  /// Fetches route geometry between multiple waypoints
  ///
  /// [waypoints] - List of latitude/longitude points to route between
  /// [profile] - Routing profile (driving, walking, cycling)
  ///
  /// Returns list of coordinates that follow actual roads
  Future<List<LatLng>> fetchRouteGeometry(
    List<LatLng> waypoints, {
    String profile = 'driving',
  }) async {
    if (waypoints.length < 2) {
      return waypoints;
    }

    try {
      // Format coordinates as "lon1,lat1;lon2,lat2;..."
      final coords = waypoints
          .map((wp) => "${wp.longitude},${wp.latitude}")
          .join(";");

      final url = Uri.parse(
        '$_baseUrl/route/v1/$profile/$coords?overview=full&geometries=geojson',
      );

      _logger.d('Fetching route from OSRM: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry'];

        // Extract coordinates from GeoJSON
        final coordinates = geometry['coordinates'] as List;
        return coordinates
            .map(
              (coord) => LatLng(
                coord[1] as double,
                coord[0] as double,
              ), // Note: GeoJSON uses [lon,lat] format
            )
            .toList();
      } else {
        _logger.e('Failed to fetch route geometry: ${response.statusCode}');
        throw Exception(
          'Failed to fetch route geometry: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Error during route fetching: $e');
      // Return straight-line path as fallback
      return waypoints;
    }
  }
}
