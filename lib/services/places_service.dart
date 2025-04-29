import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import '../configs/secure_config.dart';

class PlacesService {
  late final GoogleMapsPlaces _places;

  PlacesService() {
    _init();
  }

  Future<void> _init() async {
    final apiKey = await SecureConfig.getGoogleMapsKey();
    _places = GoogleMapsPlaces(apiKey: apiKey);
  }

  Future<List<Prediction>> searchPlace(String query) async {
    final response = await _places.autocomplete(query, types: ['geocode']);
    return response.predictions;
  }

  Future<LatLng?> getPlaceLocation(String placeId) async {
    final details = await _places.getDetailsByPlaceId(placeId);
    final location = details.result.geometry?.location;
    if (location != null) {
      return LatLng(location.lat, location.lng);
    }
    return null;
  }
}