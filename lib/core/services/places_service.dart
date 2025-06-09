import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/request/reverse_request.dart';
import 'package:nominatim_flutter/model/request/search_request.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
// Thêm import này

@injectable
class PlacesService {
  Future<List<NominatimResponse>> searchPlaces(String query) async {
    final baseReq = SearchRequest(
      query: query,
      limit: 10,
      addressDetails: true,
      extraTags: true,
      nameDetails: true,
      countryCodes: ['vn'],
      viewBox: ViewBox(10.3272, 9.9189, 105.8431, 105.2272),
    );

    var responses = await NominatimFlutter.instance.search(
      searchRequest: baseReq,
      language: 'vi',
    );

    if (responses.isEmpty && !query.toLowerCase().contains('cần thơ')) {
      final extReq = SearchRequest(
        query: '$query Cần Thơ',
        limit: 10,
        addressDetails: true,
        extraTags: true,
        nameDetails: true,
        countryCodes: ['vn'],
        viewBox: baseReq.viewBox,
      );
      responses = await NominatimFlutter.instance.search(
        searchRequest: extReq,
        language: 'vi',
      );
    }

    return responses;
  }

  Future<NominatimResponse?> getAddressFromCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final resp = await NominatimFlutter.instance.reverse(
        reverseRequest: ReverseRequest(
          lat: lat,
          lon: lon,
          addressDetails: true,
          extraTags: true,
          nameDetails: true,
        ),
        language: 'vi',
      );
      return resp;
    } catch (_) {
      return null;
    }
  }
}

extension NominatimResponseX on NominatimResponse {
  /// Convert the string latitude/longitude into a LatLng.
  LatLng get toLatLng {
    final dLat = double.tryParse(lat ?? '') ?? 0.0;
    final dLon = double.tryParse(lon ?? '') ?? 0.0;
    return LatLng(dLat, dLon);
  }

  /// Derive a short display name, similar to NominatimPlace.placeName.
  String get placeName {
    if (nameDetails != null && nameDetails!['name:vi'] is String) {
      final n = nameDetails!['name:vi'] as String;
      if (n.isNotEmpty) return n;
    }
    if (nameDetails != null && nameDetails!['name'] is String) {
      final n = nameDetails!['name'] as String;
      if (n.isNotEmpty) return n;
    }
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    if (address != null &&
        address!['name'] is String &&
        (address!['name'] as String).isNotEmpty) {
      return address!['name'] as String;
    }
    if (displayName != null && displayName!.contains(',')) {
      return displayName!.split(',').first.trim();
    }
    return displayName ?? '';
  }
}
