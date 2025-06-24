import 'dart:convert';

import 'package:geodesy/geodesy.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Service class to interact with OSRM (Open Source Routing Machine) API
///
/// Provides methods to fetch route geometries between multiple points following
/// actual road networks rather than straight lines.
@lazySingleton
class OsrmRoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org';
  final Logger _logger;
  final Geodesy _geodesy = Geodesy();

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
    String? bearings,
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
        _logger.e('Response body: ${response.body}');
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

  /// Lấy hình học cho tuyến đường ngược lại, cố gắng tìm một đường đi
  /// ở phía đối diện của đường (ví dụ: cho các đường cao tốc có dải phân cách).
  ///
  /// [waypoints] - Danh sách các điểm LatLng cho tuyến đường ban đầu.
  /// [profile] - Cấu hình định tuyến (lái xe, đi bộ, xe đạp).
  ///
  /// Trả về một danh sách các tọa độ cho tuyến đường ngược lại.
  Future<List<LatLng>> fetchReverseRouteGeometry(
    List<LatLng> waypoints, {
    String profile = 'driving',
  }) async {
    if (waypoints.length < 2) {
      return waypoints.reversed.toList();
    }

    try {
      // *** SỬA LỖI: Rút gọn danh sách waypoints nếu nó quá dài để tránh lỗi URL length ***
      const int maxWaypoints = 50; // Giới hạn số điểm để gửi lên OSRM
      List<LatLng> simplifiedWaypoints = List.from(waypoints);
      if (waypoints.length > maxWaypoints) {
        simplifiedWaypoints = [];
        // Lấy các điểm cách đều nhau
        final step = (waypoints.length / maxWaypoints).ceil();
        for (int i = 0; i < waypoints.length; i += step) {
          simplifiedWaypoints.add(waypoints[i]);
        }
        // Luôn đảm bảo điểm cuối cùng được thêm vào
        if (simplifiedWaypoints.last != waypoints.last) {
          simplifiedWaypoints.add(waypoints.last);
        }
      }

      // 1. Đảo ngược các điểm tham chiếu (đã được rút gọn) cho chuyến đi về
      final reversedWaypoints = simplifiedWaypoints.reversed.toList();

      // 2. Tính toán các góc phương vị cho tuyến đường ban đầu (đã rút gọn)
      List<double> originalBearings = [];
      for (int i = 0; i < simplifiedWaypoints.length - 1; i++) {
        originalBearings.add(
          _geodesy.bearingBetweenTwoGeoPoints(
                simplifiedWaypoints[i],
                simplifiedWaypoints[i + 1],
              )
              as double,
        );
      }
      if (originalBearings.isNotEmpty) {
        originalBearings.add(originalBearings.last);
      }

      // 3. Tạo các góc phương vị cho tuyến đường NGƯỢC LẠI
      final reversedBearings =
          originalBearings
              .map((bearing) => (bearing + 180) % 360)
              .toList()
              .reversed
              .toList();

      // 4. Định dạng tham số bearings cho truy vấn OSRM
      final bearingsString = reversedBearings
          .map((bearing) => "${bearing.round()},45")
          .join(';');

      // Định dạng tọa độ cho tuyến đường đảo ngược
      final coords = reversedWaypoints
          .map((wp) => "${wp.longitude},${wp.latitude}")
          .join(";");

      // Bỏ 'approaches=curb' vì nó có thể quá nghiêm ngặt và gây lỗi
      final url = Uri.parse(
        '$_baseUrl/route/v1/$profile/$coords?overview=full&geometries=geojson&bearings=$bearingsString',
      );

      _logger.d('Fetching REVERSE route from OSRM: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          return coordinates
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();
        }
      }

      // Nếu thất bại, thử lại mà không có bearings như một phương án dự phòng
      _logger.w(
        'Failed to fetch reverse route with bearings, falling back to simple reversed route. Status: ${response.statusCode}',
      );
      return await fetchRouteGeometry(
        waypoints.reversed.toList(),
        profile: profile,
      );
    } catch (e) {
      _logger.e('Error during reverse route fetching: $e');
      // Phương án dự phòng cuối cùng: chỉ trả về danh sách các điểm đã đảo ngược
      return waypoints.reversed.toList();
    }
  }
}
