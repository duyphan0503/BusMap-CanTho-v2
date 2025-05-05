import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PlacesService {
  Future<List<NominatimPlace>> searchPlaces(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json&addressdetails=1'
      '&limit=5'
      '&countrycodes=vn'
      '&viewbox=104.5,10.0,106.0,10.5',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'busmapcantho'},
    );
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as List;
    return data.map((e) => NominatimPlace.fromJson(e)).toList();
  }
}

class NominatimPlace {
  final String displayName;
  final double lat;
  final double lon;

  NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
    );
  }

  LatLng get toLatLng => LatLng(lat, lon);
}
