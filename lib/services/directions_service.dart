import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../configs/secure_config.dart';

class DirectionsService {
  Future<Map<String, dynamic>> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final apiKey = await SecureConfig.getGoogleMapsKey();
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch directions');
    }

    final data = jsonDecode(response.body);
    if (data['status'] != 'OK') {
      throw Exception('Directions API error: ${data['status']}');
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];
    final polyline = route['overview_polyline']['points'];

    // Decode polyline
    final polylinePoints = PolylinePoints().decodePolyline(polyline);
    final List<LatLng> points =
        polylinePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

    return {
      'polyline': points,
      'distance': leg['distance']['text'],
      'duration': leg['duration']['text'],
    };
  }
}
