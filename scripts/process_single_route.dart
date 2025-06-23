// scripts/process_single_route.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

// Helper classes to store processing results
class RouteData {
  final Map<String, dynamic> relation;
  final List<Map<String, dynamic>> sortedStops;
  final int direction;
  final String routeId;

  RouteData({
    required this.relation,
    required this.sortedStops,
    required this.direction,
    required this.routeId,
  });
}

class RouteStopEntry {
  final String routeId;
  final int stopId;
  final int sequence;
  final int direction;

  RouteStopEntry({
    required this.routeId,
    required this.stopId,
    required this.sequence,
    required this.direction,
  });
}

// Hàm helper để gọi API Overpass và xử lý lỗi
Future<List<dynamic>> callOverpassApi(String query) async {
  print('Đang thực thi truy vấn Overpass...');
  final response = await http.post(
    Uri.parse('https://overpass-api.de/api/interpreter'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'data=$query',
  );

  if (response.statusCode == 200) {
    print('Truy vấn thành công!');
    final data = json.decode(utf8.decode(response.bodyBytes));
    return data['elements'] as List;
  } else {
    print('Lỗi khi gọi API! Mã trạng thái: ${response.statusCode}');
    print('Nội dung lỗi: ${response.body}');
    throw Exception('Lỗi Overpass API');
  }
}

// Hàm mới: Lấy địa chỉ từ tọa độ bằng Nominatim API
Future<String> getAddressFromCoordinates(double lat, double lon) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1&accept-language=vi',
  );
  try {
    // Thêm User-Agent để tuân thủ chính sách của Nominatim
    final response = await http.get(
      url,
      headers: {'User-Agent': 'BusMapCanThoDataScript/1.0'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Thay thế ký tự ' để tránh lỗi SQL
      return (data['display_name'] ?? 'Không rõ địa chỉ').replaceAll("'", "''");
    }
  } catch (e) {
    // Bỏ qua lỗi và trả về chuỗi rỗng để script không bị dừng
    print('Lỗi khi lấy địa chỉ cho ($lat, $lon): $e');
  }
  return '';
}

// Hàm tính khoảng cách giữa hai điểm theo tọa độ lat/lon
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // in meters
  final double lat1Rad = lat1 * (pi / 180);
  final double lat2Rad = lat2 * (pi / 180);
  final double deltaLat = (lat2 - lat1) * (pi / 180);
  final double deltaLon = (lon2 - lon1) * (pi / 180);

  final double a =
      sin(deltaLat / 2) * sin(deltaLat / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

// Hàm mới: Xử lý một tuyến đơn và trả về dữ liệu đã xử lý
Future<RouteData> processSingleRelation(int relationId, int direction) async {
  print('--- ĐANG XỬ LÝ TUYẾN ID $relationId (Chiều: $direction) ---');

  // Truy vấn để lấy dữ liệu tuyến
  final String overpassQuery = '''
    [out:json][timeout:60];
    relation($relationId) -> .route;
    (
      node(r.route:"platform");
      node(r.route:"platform_entry_only");
      node(r.route:"platform_exit_only");
      node(r.route:"stop");
    ) -> .stops;
    (
      .route;
      .stops;
    );
    out body;
    >;
    out skel qt;
  ''';

  final allElements = await callOverpassApi(overpassQuery);

  // Tìm relation trong kết quả
  final routeRelation = allElements.firstWhere(
    (el) => el['type'] == 'relation' && el['id'] == relationId,
    orElse: () => null,
  );

  if (routeRelation == null) {
    throw Exception('Không tìm thấy tuyến (relation) với ID $relationId.');
  }

  // Tách các loại thành phần ra để dễ xử lý
  final stopMembers =
      (routeRelation['members'] as List)
          .where(
            (m) =>
                m['type'] == 'node' &&
                (m['role'].toString().contains('platform') ||
                    m['role'] == 'stop'),
          )
          .toList();
  final allNodes = {
    for (var el in allElements.where((e) => e['type'] == 'node')) el['id']: el,
  };

  // Tìm node bắt đầu và kết thúc
  final entryNodeMember = stopMembers.firstWhere(
    (m) => m['role'] == 'platform_entry_only',
    orElse: () => null,
  );
  final exitNodeMember = stopMembers.firstWhere(
    (m) => m['role'] == 'platform_exit_only',
    orElse: () => null,
  );

  // Thu thập tất cả các stops từ relation
  final stopNodes = <int, Map<String, dynamic>>{};
  for (final member in stopMembers) {
    final nodeId = member['ref'] as int;
    if (allNodes.containsKey(nodeId)) {
      stopNodes[nodeId] = allNodes[nodeId]!;
    }
  }

  print('Tìm thấy ${stopNodes.length} trạm dừng trong relation.');

  // --- THUẬT TOÁN SẮP XẾP TRẠM MỚI: NEAREST NEIGHBOR ---
  print('Bắt đầu sắp xếp các trạm theo thuật toán "Nearest Neighbor"...');

  List<Map<String, dynamic>> sortedStops = [];
  Set<int> processedStopIds = {};

  // Bước 1: Bắt đầu với trạm entry_point
  int? currentStopId;
  Map<String, dynamic>? currentStop;

  // Nếu có trạm bắt đầu, sử dụng nó làm điểm bắt đầu
  if (entryNodeMember != null) {
    currentStopId = entryNodeMember['ref'] as int;
    if (allNodes.containsKey(currentStopId)) {
      currentStop = allNodes[currentStopId]!;
      sortedStops.add(currentStop!);
      processedStopIds.add(currentStopId);
      print('Bắt đầu từ trạm platform_entry_only: ID $currentStopId');
    } else {
      print(
        'Cảnh báo: Không tìm thấy thông tin cho trạm entry_point có ID: $currentStopId',
      );
    }
  }

  // Nếu không có entry point hoặc không tìm thấy thông tin của nó, chọn một trạm bất kỳ để bắt đầu
  if (currentStop == null) {
    var firstStopId = stopNodes.keys.first;
    currentStop = stopNodes[firstStopId]!;
    currentStopId = firstStopId;
    sortedStops.add(currentStop);
    processedStopIds.add(currentStopId);
    print('Không tìm thấy entry_point, bắt đầu từ trạm ID $currentStopId');
  }

  // Bước 2: Lặp cho đến khi tất cả các trạm đã được xử lý
  while (processedStopIds.length < stopNodes.length) {
    double minDistance = double.infinity;
    int? nearestStopId;

    // Tìm trạm gần nhất với trạm hiện tại từ các trạm chưa được xử lý
    for (var stopId in stopNodes.keys) {
      if (processedStopIds.contains(stopId)) continue;

      final stop = stopNodes[stopId]!;
      final distance = calculateDistance(
        currentStop!['lat'] as double,
        currentStop['lon'] as double,
        stop['lat'] as double,
        stop['lon'] as double,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestStopId = stopId;
      }
    }

    if (nearestStopId != null) {
      final nearestStop = stopNodes[nearestStopId]!;
      sortedStops.add(nearestStop);
      processedStopIds.add(nearestStopId);
      currentStop = nearestStop;
      currentStopId = nearestStopId;

      // In thông tin để debug
      if (processedStopIds.length % 10 == 0 ||
          processedStopIds.length == stopNodes.length) {
        print(
          'Đã sắp xếp: ${processedStopIds.length}/${stopNodes.length} trạm',
        );
      }
    } else {
      // Điều này không nên xảy ra, nhưng để đề phòng
      print('Lỗi: Không thể tìm trạm gần nhất tiếp theo');
      break;
    }
  }

  // Nếu có trạm exit_only và nó không phải là trạm cuối cùng, di chuyển nó xuống cuối
  if (exitNodeMember != null) {
    final exitNodeId = exitNodeMember['ref'] as int;
    if (processedStopIds.contains(exitNodeId) &&
        sortedStops.last['id'] != exitNodeId) {
      // Tìm vị trí của exit node trong danh sách đã sắp xếp
      int exitNodeIndex = sortedStops.indexWhere(
        (stop) => stop['id'] == exitNodeId,
      );
      if (exitNodeIndex != -1) {
        // Di chuyển exit node xuống cuối danh sách
        final exitNode = sortedStops[exitNodeIndex];
        sortedStops.removeAt(exitNodeIndex);
        sortedStops.add(exitNode);
        print(
          'Đã di chuyển trạm exit_only (ID: $exitNodeId) xuống vị trí cuối cùng trong danh sách',
        );
      }
    }
  }

  print(
    'Sắp xếp hoàn tất. Tìm thấy ${sortedStops.length} trạm theo thứ tự khoảng cách.',
  );

  // Lấy routeId từ route data
  final routeTags = routeRelation['tags'];
  final routeRef = routeTags['ref'] ?? routeRelation['id'].toString();
  final routeId = 'route_${routeRef.replaceAll(' ', '_')}';

  return RouteData(
    relation: routeRelation,
    sortedStops: sortedStops,
    direction: direction,
    routeId: routeId,
  );
}

Future<void> main() async {
  // Định nghĩa các relationId để xử lý và chiều tương ứng
  final relationConfigs = [
    // route_09
    {'id': 17924282, 'direction': 0}, // chiều đi
    {'id': 17924283, 'direction': 1}, // chiều về
    // route_14
    {'id': 19053685, 'direction': 0},
    {'id': 19053686, 'direction': 1},
    // route_11
    {'id': 17924698, 'direction': 0},
    {'id': 17924699, 'direction': 1},
    // route_08
    {'id': 17756749, 'direction': 0},
    {'id': 17924280, 'direction': 1},
    // route_05
    {'id': 17686152, 'direction': 0},
    {'id': 17638669, 'direction': 1},
    // route_07
    {'id': 17723155, 'direction': 0},
    {'id': 17723156, 'direction': 1},
    // route_06
    {'id': 17723055, 'direction': 0},
    {'id': 17723056, 'direction': 1},
    // route_01-03
    {'id': 17610754, 'direction': 0},
    {'id': 17609894, 'direction': 1},
  ];

  try {
    // --- BƯỚC 1: XỬ LÝ TẤT CẢ CÁC TUYẾN ---
    print('=== BẮT ĐẦU XỬ LÝ CÁC TUYẾN ===');

    // Map để lưu tất cả các trạm duy nhất từ tất cả các tuyến
    final Map<int, Map<String, dynamic>> allUniqueStops = {};

    // Danh sách lưu thông tin route_stops cho mỗi tuyến
    final List<RouteData> allRouteData = [];

    // Danh sách lưu thông tin route_stops
    final List<RouteStopEntry> allRouteStops = [];

    // 1.1 Xử lý từng tuyến và thu thập dữ liệu
    for (final config in relationConfigs) {
      final relationId = config['id'] as int;
      final direction = config['direction'] as int;

      final routeData = await processSingleRelation(relationId, direction);
      allRouteData.add(routeData);

      // Thu thập tất cả các trạm duy nhất
      for (final stop in routeData.sortedStops) {
        final stopId = stop['id'] as int;
        if (!allUniqueStops.containsKey(stopId)) {
          allUniqueStops[stopId] = stop;
        }
      }

      // Thu thập thông tin route_stops
      int sequence = 1;
      for (final stop in routeData.sortedStops) {
        final stopId = stop['id'] as int;
        allRouteStops.add(
          RouteStopEntry(
            routeId: routeData.routeId,
            stopId: stopId,
            sequence: sequence++,
            direction: direction,
          ),
        );
      }
    }

    print(
      '\nĐã thu thập ${allUniqueStops.length} trạm duy nhất từ tất cả các chiều tuyến.',
    );

    // --- BƯỚC 2: CHUẨN BỊ DỮ LIỆU SQL ---
    print('=== ĐANG CHUẨN BỊ DỮ LIỆU SQL ===');

    // Lấy thông tin tuyến từ relation đầu tiên (các thông tin tuyến nên giống nhau)
    final firstRouteData = allRouteData.first;
    final routeTags = firstRouteData.relation['tags'];
    final routeId = firstRouteData.routeId;
    final routeNumber = (routeTags['ref'] ?? 'N/A').replaceAll("'", "''");
    final routeName = (routeTags['name'] ?? 'Tuyến $routeNumber').replaceAll(
      "'",
      "''",
    );
    final description = (routeTags['description'] ??
            (routeTags['from'] != null && routeTags['to'] != null
                ? '${routeTags['from']} - ${routeTags['to']}'
                : ''))
        .replaceAll("'", "''");

    final operatingHours = (routeTags['opening_hours'] ?? '').replaceAll(
      "'",
      "''",
    );
    final frequency = (routeTags['interval'] ?? '').replaceAll("'", "''");
    final fare = (routeTags['charge'] ?? '').replaceAll("'", "''");
    const String routeType = 'Nội thành';
    const String agencyId = 'agency_01'; // Giá trị mặc định

    // Chuẩn bị SQL
    final StringBuffer sqlRoutes = StringBuffer('-- Dữ liệu cho bảng ROUTES\n');
    final StringBuffer sqlStops = StringBuffer('-- Dữ liệu cho bảng STOPS\n');
    final StringBuffer sqlRouteStops = StringBuffer(
      '-- Dữ liệu cho bảng ROUTE_STOPS\n',
    );

    // Tạo SQL cho bảng routes - chỉ một lần
    sqlRoutes.writeln(
      "INSERT INTO public.routes (id, route_number, route_name, description, operating_hours_description, frequency_description, fare_info, route_type, agency_id) VALUES ('$routeId', '$routeNumber', '$routeName', '$description', '$operatingHours', '$frequency', '$fare', '$routeType', '$agencyId');",
    );

    // Trước khi tạo SQL, cần chuẩn bị tên và địa chỉ cho tất cả các trạm
    Map<int, String> stopNames = {}; // {stopId: stopName}
    Map<int, String> stopAddresses = {}; // {stopId: address}
    Map<int, String> stopGeneratedNames = {}; // {stopId: generatedName}
    Map<String, List<int>> addressToStopIds =
        {}; // {address: [stopId1, stopId2, ...]}

    print('\nĐang chuẩn bị tên và địa chỉ cho các trạm...');

    // Bước 1: Thu thập tên và địa chỉ cho tất cả các trạm
    for (final stopId in allUniqueStops.keys) {
      final stopData = allUniqueStops[stopId]!;
      final stopTags = stopData['tags'] ?? {};
      final lat = stopData['lat'] as double;
      final lon = stopData['lon'] as double;

      // Lấy tên trạm từ tags nếu có
      String stopName =
          stopTags['name:vi'] ?? stopTags['name'] ?? 'Trạm không tên';

      // Lấy địa chỉ từ tags nếu có
      String address = stopTags['addr:full'] ?? '';

      // Nếu trạm không có địa chỉ, gọi API để lấy
      if (address.isEmpty) {
        print(
          "...Trạm ID $stopId không có địa chỉ. Đang tìm địa chỉ từ tọa độ...",
        );
        address = await getAddressFromCoordinates(lat, lon);
        // Thêm độ trễ nhỏ để không spam API
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Lưu thông tin vào map
      stopNames[stopId] = stopName;
      stopAddresses[stopId] = address;

      // Tạo tên tự động nếu cần
      if (stopName == 'Trạm không tên' && address.isNotEmpty) {
        String generatedName = address.split(',').first;
        stopGeneratedNames[stopId] = generatedName;

        // Theo dõi các trạm có cùng địa chỉ
        if (!addressToStopIds.containsKey(generatedName)) {
          addressToStopIds[generatedName] = [];
        }
        addressToStopIds[generatedName]!.add(stopId);
      }
    }

    // Bước 2: Xử lý các trạm có tên được tạo tự động trùng nhau
    print('Kiểm tra và xử lý các trạm có tên tự động trùng nhau...');
    for (var addressName in addressToStopIds.keys) {
      final stopIds = addressToStopIds[addressName]!;
      if (stopIds.length > 1) {
        print(
          'Phát hiện ${stopIds.length} trạm có tên tự động giống nhau: "$addressName"',
        );

        // Thêm số thứ tự cho các trạm trùng tên
        for (int i = 0; i < stopIds.length; i++) {
          stopNames[stopIds[i]] = '$addressName (${i + 1})';
          print(
            '  - Trạm ID ${stopIds[i]}: đổi tên thành "${stopNames[stopIds[i]]}"',
          );
        }
      } else if (stopIds.length == 1) {
        // Nếu chỉ có 1 trạm với tên này, sử dụng tên tự động
        stopNames[stopIds[0]] = addressName;
      }
    }

    // Tạo SQL cho bảng stops - chỉ một lần cho mỗi trạm duy nhất
    print('Đang tạo SQL cho ${allUniqueStops.length} trạm duy nhất...');
    for (final stopId in allUniqueStops.keys) {
      final stopData = allUniqueStops[stopId]!;
      final stopTags = stopData['tags'] ?? {};
      final stopDbId = 'stop_$stopId';
      final stopCode = (stopTags['ref'] ?? 'CT$stopId').replaceAll("'", "''");

      // Sử dụng tên đã được xử lý trùng lặp
      String stopName = stopNames[stopId]!.replaceAll("'", "''");
      final lat = stopData['lat'];
      final lon = stopData['lon'];
      String address = stopAddresses[stopId]!.replaceAll("'", "''");

      sqlStops.writeln(
        "INSERT INTO public.stops (id, stop_code, name, address, location) VALUES ('$stopDbId', '$stopCode', '$stopName', '$address', ST_SetSRID(ST_MakePoint($lon, $lat), 4326));",
      );
    }

    // Tạo SQL cho bảng route_stops - theo thứ tự của mỗi tuyến/chiều
    print('Đang tạo SQL cho các route_stops theo từng chiều...');
    for (final routeStop in allRouteStops) {
      final routeStopId =
          'rs_${routeStop.routeId}_${routeStop.direction}_${routeStop.sequence}';
      final stopDbId = 'stop_${routeStop.stopId}';

      sqlRouteStops.writeln(
        "INSERT INTO public.route_stops (id, route_id, stop_id, sequence, direction) VALUES ('$routeStopId', '${routeStop.routeId}', '$stopDbId', ${routeStop.sequence}, ${routeStop.direction});",
      );
    }

    // --- BƯỚC 3: GHI RA FILE ---
    final routeRef = routeNumber.replaceAll(' ', '_');
    final outputFile = File('output_route_${routeRef}_both_directions.sql');
    final writer = outputFile.openWrite();

    writer.writeln(
      '-- Dữ liệu được tạo tự động cho tuyến $routeNumber (cả hai chiều) lúc ${DateTime.now()}',
    );
    writer.writeln(
      '-- Chạy các lệnh này trong SQL Editor của Supabase để chèn dữ liệu.\n',
    );
    writer.writeln(sqlRoutes.toString());
    writer.writeln(sqlStops.toString());
    writer.writeln(sqlRouteStops.toString());
    await writer.flush();
    await writer.close();

    print('\nHOÀN TẤT!');
    print(
      'Đã tạo file `${outputFile.path}` với thông tin cho cả hai chiều của tuyến, tổng cộng ${allUniqueStops.length} trạm duy nhất.',
    );
  } catch (e) {
    print('Đã xảy ra lỗi không mong muốn: $e');
  }
}
