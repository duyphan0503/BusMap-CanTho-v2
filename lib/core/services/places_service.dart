import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@injectable
class PlacesService {
  Future<List<NominatimPlace>> searchPlaces(String query) async {
    // Tìm kiếm với truy vấn gốc
    var results = await _performSearch(query);
    
    // Nếu không có kết quả, thử thêm "Cần Thơ" vào truy vấn
    if (results.isEmpty && !query.toLowerCase().contains('cần thơ')) {
      final extendedQuery = '$query Cần Thơ';
      results = await _performSearch(extendedQuery);
    }
    
    // Lọc kết quả để chỉ giữ các địa điểm có từ khóa trong tên
    final queryLower = query.toLowerCase();
    results = results.where((place) {
      final placeName = place.placeName.toLowerCase();
      return placeName.contains(queryLower);
    }).toList();
    
    return results;
  }
  
  Future<List<NominatimPlace>> _performSearch(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json'
      '&addressdetails=1'
      '&namedetails=1'       // Thêm chi tiết tên
      '&extratags=1'         // Thêm tags mở rộng
      '&limit=10'            // Tăng giới hạn kết quả
      '&countrycodes=vn'
      '&dedupe=1'            // Loại bỏ trùng lặp
      '&bounded=1'           // Không bị giới hạn chặt chẽ trong viewbox
      '&viewbox=105.13504,10.32843,106.00571,9.92557'
      '&accept-language=vi'
    );
    
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'busmapcantho'},
      );
      
      if (response.statusCode != 200) return [];
      
      final data = jsonDecode(response.body) as List;
      final places = data.map((e) => NominatimPlace.fromJson(e)).toList();
      
      // Sắp xếp kết quả theo mức độ liên quan
      places.sort((a, b) {
        // Ưu tiên địa điểm có tên khớp chính xác với truy vấn
        final queryLower = query.toLowerCase();
        final aNameMatch = a.placeName.toLowerCase().contains(queryLower);
        final bNameMatch = b.placeName.toLowerCase().contains(queryLower);
        
        if (aNameMatch && !bNameMatch) return -1;
        if (!aNameMatch && bNameMatch) return 1;
        
        // Sau đó xếp theo importance (nếu có)
        if (a.importance != null && b.importance != null) {
          final aImportance = double.tryParse(a.importance!) ?? 0;
          final bImportance = double.tryParse(b.importance!) ?? 0;
          return bImportance.compareTo(aImportance); // Cao đến thấp
        }
        
        return 0;
      });
      
      return places;
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Thêm hàm này để lấy địa chỉ từ lat/lng bằng Nominatim API
  Future<NominatimPlace?> getAddressFromCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lon&format=json&addressdetails=1&namedetails=1&extratags=1&accept-language=vi'
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'busmapcantho'},
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      return NominatimPlace(
        displayName: data['display_name'] ?? '',
        lat: double.tryParse(data['lat']?.toString() ?? '') ?? lat,
        lon: double.tryParse(data['lon']?.toString() ?? '') ?? lon,
        type: data['type']?.toString(),
        importance: data['importance']?.toString(),
        address: data['address'] != null ? Address.fromJson(data['address']) : null,
        name: data['name']?.toString(),
        nameDetails: data['namedetails'] as Map<String, dynamic>?,
        extraTags: data['extratags'] as Map<String, dynamic>?,
      );
    } catch (e) {
      print('Reverse geocode error: $e');
      return null;
    }
  }
}

class Address {
  final String? road;
  final String? suburb;
  final String? county;
  final String? state;
  final String? postcode;
  final String? type;
  final String? name;
  final String? district;
  final String? neighbourhood;
  final String? houseNumber;
  final String? city;

  Address({
    this.road,
    this.suburb,
    this.county,
    this.state,
    this.postcode,
    this.type,
    this.name,
    this.district,
    this.neighbourhood,
    this.houseNumber,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      road: json['road'] as String?,
      suburb: json['suburb'] as String?,
      county: json['county'] as String?,
      state: json['state'] as String?,
      postcode: json['postcode'] as String?,
      // Type of location (amenity, building, etc.)
      type: json['amenity'] ?? json['building'] ?? json['office'] ?? json['shop'],
      // Lấy tên địa điểm nếu có
      name: json['name'] as String?,
      // Thêm các trường địa chỉ khác có thể có trong dữ liệu trả về
      district: json['district'] as String?,
      neighbourhood: json['neighbourhood'] as String?,
      houseNumber: json['house_number'] as String?,
      city: json['city'] as String?,
    );
  }
}

class NominatimPlace {
  final String displayName;
  final double lat;
  final double lon;
  final String? type;
  final String? importance;
  final Address? address;
  final String? name;
  final Map<String, dynamic>? nameDetails;
  final Map<String, dynamic>? extraTags;

  NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.type,
    this.importance,
    this.address,
    this.name,
    this.nameDetails,
    this.extraTags,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
      type: json['type'] as String?,
      importance: json['importance']?.toString(),
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      name: json['name'] as String?,
      nameDetails: json['namedetails'] as Map<String, dynamic>?,
      extraTags: json['extratags'] as Map<String, dynamic>?,
    );
  }

  LatLng get toLatLng => LatLng(lat, lon);

  // Lấy tên ngắn gọn của địa điểm
  String get placeName {
    // Ưu tiên sử dụng name từ nameDetails
    if (nameDetails != null && nameDetails!.containsKey('name:vi')) {
      return nameDetails!['name:vi'];
    }
    
    if (nameDetails != null && nameDetails!.containsKey('name')) {
      return nameDetails!['name'];
    }
    
    // Tiếp tục với các phương pháp hiện tại
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    
    // Nếu có address.name thì sử dụng
    if (address?.name != null && address!.name!.isNotEmpty) {
      return address!.name!;
    }
    
    // Nếu không có name, thử lấy phần đầu của displayName (trước dấu phẩy đầu tiên)
    final firstComma = displayName.indexOf(',');
    if (firstComma > 0) {
      return displayName.substring(0, firstComma).trim();
    }
    
    // Nếu không có dấu phẩy, trả về toàn bộ displayName
    return displayName;
  }
}
