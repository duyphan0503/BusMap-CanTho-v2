import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:nominatim_flutter/model/request/reverse_request.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';

// Thêm import này
final logger = Logger();

@injectable
class PlacesService {
  Future<List<NominatimResponse>> searchPlaces(String query) async {
    try {
      final q = Uri.encodeComponent(query.trim());

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$q'
        '&format=jsonv2'
        '&limit=15'
        '&addressdetails=1'
        '&namedetails=1'
        '&countrycodes=vn'
        '&viewbox=105.22,10.325,106.29,9.238'
        '&bounded=1'
        '&accept-language=vi',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'busmapcantho/2.0', // Cập nhật User-Agent
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        // Chuyển đổi List<dynamic> thành List<NominatimResponse>
        return data
            .map(
              (item) =>
                  NominatimResponse.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        logger.w('Nominatim HTTP error: ${response.statusCode}');
        throw Exception('Không thể tìm kiếm địa điểm. Vui lòng thử lại sau.');
      }
    } catch (e, stackTrace) {
      logger.e('Nominatim search failed', error: e, stackTrace: stackTrace);
      throw Exception(
        'Đã xảy ra lỗi khi tìm kiếm. Kiểm tra kết nối mạng hoặc thử lại sau.',
      );
    }
  }
  /*Future<List<NominatimResponse>> searchPlaces(String query) async {
    // 1. Tối ưu hóa query: Luôn thêm "Cần Thơ" để tăng độ chính xác và
    // tránh phải thực hiện cuộc gọi thứ hai.
    */ /*final normalizedQuery =
        query.toLowerCase().contains('cần thơ') ? query : '$query, Cần Thơ';*/ /*

    final request = SearchRequest(
      query: query,
      limit: 15, // Tăng giới hạn kết quả để có nhiều lựa chọn hơn
      addressDetails: true,
      nameDetails: true,
      extraTags: false, // TẮT extraTags để giảm kích thước payload
      countryCodes: ['vn'],
      language: 'vi',
      // Giữ viewBox để ưu tiên kết quả trong khu vực Cần Thơ
      viewBox: ViewBox(10.32664, 9.24131, 106.29204, 105.22533),
    );

    // 2. Chỉ có MỘT lần `await` duy nhất.
    // Kết quả sẽ nhanh hơn đáng kể vì không còn kịch bản chờ đợi lần thứ hai.
    final responses = await NominatimFlutter.instance.search(
      searchRequest: request,
      language: 'vi',
    );

    return responses;
  }*/

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
