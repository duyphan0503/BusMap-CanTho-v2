/// simulate_buses.dart
/// -------------------
/// Script mô phỏng hoạt động xe buýt, cập nhật vị trí, hướng, tốc độ, trạng thái lên Supabase.
///
/// - Định nghĩa các model Stop, Bus.
/// - Lấy dữ liệu điểm dừng từ Supabase.
/// - Mô phỏng di chuyển xe buýt, cập nhật vị trí liên tục.
/// - Gửi dữ liệu vị trí xe buýt lên Supabase.
///
/// Cách sử dụng:
///   dart run scripts/simulate_buses.dart
///
/// Tác giả: Duy Phan
/// Ngày tạo: 2025-06-13
library;

import 'dart:async';

import 'package:busmapcantho/configs/env.dart';
import 'package:busmapcantho/core/utils/geo_utils.dart';
import 'package:geodesy/geodesy.dart';
import 'package:logger/logger.dart';
import 'package:supabase/supabase.dart';

// ==================== Config =====================
/// Khởi tạo client Supabase, logger, random và geodesy cho mô phỏng.
final supabase = SupabaseClient(
  baseUrl,
  serviceRoleKey, // Lấy trong Supabase Dashboard > Project API > Service role
);

final logger = Logger();

final random = Random();

final geodesy = Geodesy();

// ==================== Model =====================
/// Đại diện cho một điểm dừng xe buýt với tọa độ địa lý.
class Stop {
  /// Vĩ độ điểm dừng.
  final double lat;

  /// Kinh độ điểm dừng.
  final double lng;

  /// Tạo một điểm dừng với [lat] và [lng].
  Stop(this.lat, this.lng);
}

/// Đại diện cho một xe buýt mô phỏng di chuyển trên tuyến.
class Bus {
  /// Mã định danh xe buýt.
  final String vehicleId;

  /// Mã định danh tuyến xe buýt.
  final String routeId;

  /// Danh sách các điểm dừng của tuyến.
  final List<Stop> stops;

  /// Vị trí điểm dừng hiện tại (index trong [stops]).
  int fromIndex;

  /// Vị trí điểm dừng tiếp theo (index trong [stops]).
  int toIndex;

  /// Hướng di chuyển: 1 (đi tới), -1 (quay đầu).
  int direction;

  /// Tiến trình di chuyển giữa hai điểm dừng (0..1).
  double progress;

  /// Tốc độ hiện tại (mét/giây).
  double speed;

  /// Số giây còn lại phải dừng ở trạm.
  int pauseAtStop;

  /// Góc phương vị di chuyển (độ).
  double bearing;

  /// Trạng thái chỗ ngồi ("low", "medium", "full").
  String occupancyStatus;

  /// Khởi tạo một xe buýt mô phỏng.
  Bus({
    required this.vehicleId,
    required this.routeId,
    required this.stops,
    required this.fromIndex,
    required this.toIndex,
    required this.direction,
    this.progress = 0,
    this.speed = 10,
    this.pauseAtStop = 0,
    this.bearing = 0,
    this.occupancyStatus = "medium",
  });

  /// Di chuyển xe buýt một bước mô phỏng, cập nhật vị trí, hướng, tốc độ, trạng thái.
  /// Trả về vị trí mới của xe buýt (Stop).
  Future<Stop> moveStep() async {
    if (pauseAtStop > 0) {
      pauseAtStop--;
      return stops[fromIndex];
    }

    // Random tốc độ mỗi bước (6-18 m/s)
    speed = 6 + random.nextDouble() * 12;

    // Ngẫu nhiên trạng thái lấp đầy mỗi khi xe buýt rời trạm dừng
    if (progress == 0) {
      final index = random.nextInt(3);
      occupancyStatus = ["low", "medium", "full"][index];
    }

    final from = stops[fromIndex];
    final to = stops[toIndex];
    final fromLatLng = LatLng(from.lat, from.lng);
    final toLatLng = LatLng(to.lat, to.lng);

    // Sử dụng geodesy để tính distance và bearing
    final distance = geodesy.distanceBetweenTwoGeoPoints(fromLatLng, toLatLng);
    bearing =
        geodesy.bearingBetweenTwoGeoPoints(fromLatLng, toLatLng).toDouble();

    double step = (speed / distance).toDouble();
    progress += step;

    if (progress >= 1.0) {
      fromIndex = toIndex;
      // Nếu tới cuối tuyến thì quay đầu
      /*if ((direction == 1 && fromIndex == stops.length - 1) ||
          (direction == -1 && fromIndex == 0)) {
        direction *= -1;
      }*/
      // Tạm thời không cho xe quay đầu: nếu đến cuối tuyến thì dừng lại ở đó
      if ((direction == 1 && fromIndex == stops.length - 1) ||
          (direction == -1 && fromIndex == 0)) {
        // Không đổi hướng, không cập nhật toIndex, giữ nguyên vị trí cuối
        progress = 0;
        pauseAtStop = 3 + random.nextInt(12); // Dừng lại 3-15s ở trạm
        return stops[fromIndex];
      }
      toIndex = fromIndex + direction;
      if (toIndex < 0) toIndex = 1;
      if (toIndex >= stops.length) toIndex = stops.length - 2;
      progress = 0;
      pauseAtStop = 3 + random.nextInt(12); // Dừng lại 3-15s ở trạm
      return stops[fromIndex];
    } else {
      // Sử dụng nội suy tuyến tính thủ công vì geodesy không có hàm này
      final lat = from.lat + (to.lat - from.lat) * progress;
      final lng = from.lng + (to.lng - from.lng) * progress;
      return Stop(lat.toDouble(), lng.toDouble());
    }
  }
}

// ==================== Data Access =====================
/// Lấy danh sách điểm dừng của tuyến từ Supabase.
/// [routeId]: mã tuyến, [direction]: chiều đi (0/1)
/// Trả về danh sách Stop.
Future<List<Stop>> getRouteStops(String routeId, {int direction = 0}) async {
  try {
    final res = await supabase
        .from('route_stops')
        .select('sequence, stop_id, stops(location)')
        .eq('route_id', routeId)
        .eq('direction', direction)
        .order('sequence', ascending: true);

    if (res.isEmpty) {
      throw Exception('No stops found for route $routeId direction $direction');
    }

    return res.map<Stop>((item) {
      final loc = item['stops']['location'];
      final point = GeoPoint.fromGeography(loc);

      if (point != null) {
        return Stop(point.lat, point.lng);
      }

      throw Exception('Unable to parse location data: $loc');
    }).toList();
  } catch (e, stackTrace) {
    logger.e('Error fetching route stops: $e', stackTrace: stackTrace);
    return [];
  }
}

/// Gửi vị trí, tốc độ, hướng, trạng thái xe buýt lên Supabase.
Future<void> updateBusLocation(
  String vehicleId,
  String routeId,
  Stop pos,
  double speed,
  double bearing,
  String occupancyStatus,
) async {
  final location = 'SRID=4326;POINT(${pos.lng} ${pos.lat})';
  await supabase.from('bus_locations').upsert({
    'vehicle_id': vehicleId,
    'route_id': routeId,
    'location': location,
    'timestamp': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'speed': speed,
    'bearing': bearing,
    'occupancy_status': occupancyStatus,
  });
}

// ==================== Main logic =====================
/// Hàm main khởi tạo các tuyến, xe buýt và vòng lặp mô phỏng cập nhật vị trí liên tục.
Future<void> main() async {
  try {
    // Định nghĩa các tuyến và số lượng xe mỗi tuyến
    final routes = <String, int>{
      'route_01-03': 2,
      'route_05': 2,
      'route_06': 2,
      'route_07': 2,
      'route_08': 2,
      'route_09': 2,
      'route_11': 2,
      'route_14': 2,
      // Thêm tuyến nếu muốn...
    };

    // Khởi tạo nhiều xe bus (nhiều tuyến song song)
    final List<Bus> buses = [];
    for (final entry in routes.entries) {
      final stopsForward = await getRouteStops(entry.key, direction: 0);
      final stopsReverse = await getRouteStops(entry.key, direction: 1);
      if (entry.value == 2) {
        // Outbound bus
        buses.add(
          Bus(
            vehicleId: 'bus_${entry.key}_0_outbound',
            routeId: entry.key,
            stops: stopsForward,
            fromIndex: 0,
            toIndex: 1,
            direction: 1, // forward
            progress: 0, // always start at beginning
          ),
        );
        // Inbound bus
        buses.add(
          Bus(
            vehicleId: 'bus_${entry.key}_1_inbound',
            routeId: entry.key,
            stops: stopsReverse,
            fromIndex: 0,
            toIndex: 1,
            direction: 1, // backward
            progress: 0, // always start at end
          ),
        );
      } else {
        // For other cases, keep previous logic (random direction)
        for (int i = 0; i < entry.value; i++) {
          int dir = random.nextBool() ? 0 : 1;
          List<Stop> stops = dir == 0 ? stopsForward : stopsReverse;
          int fromIndex = dir == 0 ? 0 : stops.length - 1;
          int toIndex = dir == 0 ? 1 : stops.length - 2;
          String directionLabel = dir == 0 ? 'outbound' : 'inbound';
          buses.add(
            Bus(
              vehicleId: 'bus_${entry.key}_$i"+"_$directionLabel',
              routeId: entry.key,
              stops: stops,
              fromIndex: fromIndex,
              toIndex: toIndex,
              direction: dir == 0 ? 1 : -1,
              progress: random.nextDouble(),
            ),
          );
        }
      }
    }

    // Vòng lặp chính
    const Duration interval = Duration(seconds: 1);
    while (true) {
      for (final bus in buses) {
        try {
          final pos = await bus.moveStep();
          await updateBusLocation(
            bus.vehicleId,
            bus.routeId,
            pos,
            bus.speed,
            bus.bearing,
            bus.occupancyStatus,
          );
          logger.i(
            '${bus.vehicleId} @ ${pos.lat},${pos.lng} '
            '(speed: ${bus.speed.toStringAsFixed(1)} m/s, '
            'bearing: ${bus.bearing.toStringAsFixed(1)}, '
            'occupancy: ${bus.occupancyStatus}, pause: ${bus.pauseAtStop}s)',
          );
        } catch (e, stackTrace) {
          logger.e('Error in bus loop: $e', stackTrace: stackTrace);
        }
      }
      await Future.delayed(interval);
    }
  } catch (e, stackTrace) {
    logger.e('Unhandled exception in main: $e', stackTrace: stackTrace);
  }
}
