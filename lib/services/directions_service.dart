import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@injectable
class DirectionsService {
  Future<DirectionsResult?> getDirections(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );
    final resp = await http.get(url);
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((data['routes'] as List).isEmpty) return null;
    final coords =
        (data['routes'][0]['geometry']['coordinates'] as List)
            .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
            .toList();
    final leg = (data['routes'][0]['legs'] as List).first;
    return DirectionsResult(
      polyline: coords,
      distanceText: leg['distance'].toString(),
      durationText: leg['duration'].toString(),
    );
  }
}

class DirectionsResult {
  final List<LatLng> polyline;
  final String distanceText;
  final String durationText;

  DirectionsResult({
    required this.polyline,
    required this.distanceText,
    required this.durationText,
  });
}
