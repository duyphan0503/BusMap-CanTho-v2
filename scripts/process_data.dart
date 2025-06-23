// scripts/process_data.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// Hàm helper để gọi API Overpass và xử lý lỗi
Future<List<dynamic>> callOverpassApi(String query, String purpose) async {
  print('Đang thực thi truy vấn cho: $purpose...');
  final response = await http.post(
    Uri.parse('https://overpass-api.de/api/interpreter'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'data=$query',
  );

  if (response.statusCode == 200) {
    print('Truy vấn "$purpose" thành công!');
    final data = json.decode(utf8.decode(response.bodyBytes));
    return data['elements'] as List;
  } else {
    print(
      'Lỗi khi gọi API cho "$purpose"! Mã trạng thái: ${response.statusCode}',
    );
    print('Nội dung lỗi: ${response.body}');
    throw Exception('Lỗi Overpass API cho "$purpose"');
  }
}

// Hàm mới: Lấy địa chỉ từ tọa độ bằng Nominatim API
Future<String> getAddressFromCoordinates(double lat, double lon) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1&accept-language=vi',
  );
  try {
    final response = await http.get(
      url,
      headers: {'User-Agent': 'BusMapCanThoDataScript/1.0'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['display_name'] ?? 'Không rõ địa chỉ').replaceAll("'", "''");
    }
  } catch (e) {
    // Bỏ qua lỗi và trả về chuỗi rỗng
  }
  return '';
}

Future<void> main() async {
  try {
    // --- SỬ DỤNG TRUY VẤN DUY NHẤT VÀ HOÀN CHỈNH CỦA BẠN ---
    const String overpassQuery = '''
      [out:json][timeout:90];
      area(3601874283)->.searchArea;
      relation(area.searchArea)[type=route][route=bus]["network"="Xe buýt Cần Thơ"]->.allRoutes;
      (
        node(r.allRoutes:"platform");
        node(r.allRoutes:"platform_entry_only");
        node(r.allRoutes:"platform_exit_only");
        node(r.allRoutes:"stop");
      )->.allStops;
      (
        relation.allRoutes;
        node.allStops;
      );
      out body;
    ''';
    print('--- BƯỚC 1: LẤY TOÀN BỘ DỮ LIỆU TUYẾN VÀ TRẠM ---');
    final allElements = await callOverpassApi(
      overpassQuery,
      "Lấy dữ liệu tổng hợp",
    );

    // --- BƯỚC 2: TẠO MAP ĐỂ TRA CỨU NHANH THÔNG TIN TRẠM DỪNG ---
    final Map<int, dynamic> stopDetailsMap = {
      for (var e in allElements.where((el) => el['type'] == 'node')) e['id']: e,
    };
    print(
      'Đã xử lý và lập chỉ mục ${stopDetailsMap.length} trạm dừng duy nhất.',
    );

    // --- BƯỚC 3: BẮT ĐẦU XỬ LÝ VÀ TẠO SQL ---
    print('\n--- BƯỚC 3: Đang xử lý dữ liệu và tạo file SQL... ---');

    final Map<String, String> agencies = {};
    final Set<int> processedStopIds = {};
    final Set<String> processedRouteIds = {};

    final StringBuffer sqlAgencies = StringBuffer(
      '-- Dữ liệu cho bảng AGENCIES\n',
    );
    final StringBuffer sqlRoutes = StringBuffer('-- Dữ liệu cho bảng ROUTES\n');
    final StringBuffer sqlStops = StringBuffer('-- Dữ liệu cho bảng STOPS\n');
    final StringBuffer sqlRouteStops = StringBuffer(
      '-- Dữ liệu cho bảng ROUTE_STOPS\n',
    );

    final Map<String, List<dynamic>> routesGroupedByRef = {};
    // Lọc ra các tuyến từ dữ liệu tổng hợp
    for (var element in allElements) {
      if (element['type'] == 'relation' && element['tags']?['route'] == 'bus') {
        final routeRef = element['tags']?['ref'];
        if (routeRef != null) {
          routesGroupedByRef.putIfAbsent(routeRef, () => []).add(element);
        }
      }
    }

    for (var entry in routesGroupedByRef.entries) {
      final routeRef = entry.key;
      final routeRelations = entry.value;

      final representativeRouteTags = routeRelations.first['tags'];
      String agencyName = (representativeRouteTags['operator'] ??
              'Chưa xác định')
          .replaceAll("'", "''");
      String agencyId;
      if (!agencies.containsKey(agencyName)) {
        agencyId = 'agency_${(agencies.length + 1).toString().padLeft(2, '0')}';
        agencies[agencyName] = agencyId;
        sqlAgencies.writeln(
          "INSERT INTO public.agencies (id, name) VALUES ('$agencyId', '$agencyName');",
        );
      } else {
        agencyId = agencies[agencyName]!;
      }

      final routeId = 'route_${routeRef.replaceAll(' ', '_')}';
      if (!processedRouteIds.contains(routeId)) {
        final routeNumber = routeRef.replaceAll("'", "''");
        final routeName = (representativeRouteTags['name'] ??
                'Tuyến $routeNumber')
            .replaceAll("'", "''");
        final description = (representativeRouteTags['description'] ??
                (representativeRouteTags['from'] != null &&
                        representativeRouteTags['to'] != null
                    ? '${representativeRouteTags['from']} - ${representativeRouteTags['to']}'
                    : ''))
            .replaceAll("'", "''");

        final operatingHours = (representativeRouteTags['opening_hours'] ?? '')
            .replaceAll("'", "''");
        final frequency = (representativeRouteTags['interval'] ?? '')
            .replaceAll("'", "''");
        final fare = (representativeRouteTags['charge'] ?? '').replaceAll(
          "'",
          "''",
        );
        const String routeType = 'Nội thành';

        sqlRoutes.writeln(
          "INSERT INTO public.routes (id, route_number, route_name, description, operating_hours_description, frequency_description, fare_info, route_type, agency_id) VALUES ('$routeId', '$routeNumber', '$routeName', '$description', '$operatingHours', '$frequency', '$fare', '$routeType', '$agencyId');",
        );
        processedRouteIds.add(routeId);
      }

      for (int i = 0; i < routeRelations.length; i++) {
        if (i >= 2) {
          print(
            "--- CẢNH BÁO: Tuyến '$routeRef' có nhiều hơn 2 relation. Đã bỏ qua relation thừa.",
          );
          continue;
        }

        final relation = routeRelations[i];
        final direction = i;
        int sequence = 1;

        final members = relation['members'] as List;
        for (var member in members) {
          if (member['type'] == 'node' &&
              (member['role'] == 'platform' ||
                  member['role'] == 'stop' ||
                  member['role'] == 'platform_entry_only' ||
                  member['role'] == 'platform_exit_only')) {
            final stopNodeId = member['ref'] as int;

            // **LOGIC ĐÃ SỬA:** Dữ liệu trạm được tra cứu từ Map đã được xử lý ở Bước 2
            if (stopDetailsMap.containsKey(stopNodeId)) {
              if (!processedStopIds.contains(stopNodeId)) {
                final stopNodeData = stopDetailsMap[stopNodeId];
                final stopTags = stopNodeData?['tags'] ?? {};
                final stopDbId = 'stop_$stopNodeId';
                final stopCode = (stopTags['ref'] ?? 'CT$stopNodeId')
                    .replaceAll("'", "''");
                String stopName = (stopTags['name:vi'] ??
                        stopTags['name'] ??
                        'Trạm không tên')
                    .replaceAll("'", "''");
                final lat = stopNodeData?['lat'];
                final lon = stopNodeData?['lon'];
                String address = (stopTags['addr:full'] ?? '').replaceAll(
                  "'",
                  "''",
                );

                if ((stopName == 'Trạm không tên' || address.isEmpty) &&
                    lat != null &&
                    lon != null) {
                  print(
                    "...Trạm ID $stopNodeId không có tên/địa chỉ. Đang tìm địa chỉ từ tọa độ...",
                  );
                  address = await getAddressFromCoordinates(lat, lon);
                  if (stopName == 'Trạm không tên' && address.isNotEmpty) {
                    stopName = address.split(',').first;
                  }
                  await Future.delayed(const Duration(milliseconds: 30));
                }

                sqlStops.writeln(
                  "INSERT INTO public.stops (id, stop_code, name, address, location) VALUES ('$stopDbId', '$stopCode', '$stopName', '$address', ST_SetSRID(ST_MakePoint($lon, $lat), 4326));",
                );
                processedStopIds.add(stopNodeId);
              }

              final routeStopId = 'rs_${routeId}_${direction}_$sequence';
              final stopDbId = 'stop_$stopNodeId';
              sqlRouteStops.writeln(
                "INSERT INTO public.route_stops (id, route_id, stop_id, sequence, direction) VALUES ('$routeStopId', '$routeId', '$stopDbId', $sequence, $direction);",
              );
              sequence++;
            }
            // Không cần 'else' nữa vì truy vấn mới đã đảm bảo tất cả các trạm trong members đều có trong stopDetailsMap
          }
        }
      }
    }

    final outputFile = File('output.sql');
    final writer = outputFile.openWrite();
    writer.writeln(
      '-- Dữ liệu được tạo tự động từ Overpass API lúc ${DateTime.now()}',
    );
    writer.writeln(
      'TRUNCATE TABLE public.agencies, public.stops, public.routes, public.route_stops RESTART IDENTITY CASCADE;\n',
    );
    writer.writeln(sqlAgencies.toString());
    writer.writeln(sqlRoutes.toString());
    writer.writeln(sqlStops.toString());
    writer.writeln(sqlRouteStops.toString());
    await writer.flush();
    await writer.close();

    print('\nHOÀN TẤT!');
    print(
      'Đã tạo file `output.sql` với dữ liệu đã được làm sạch và đầy đủ hơn.',
    );
    print(
      'Lưu ý: Quá trình chạy có thể mất vài phút nếu có nhiều trạm cần lấy địa chỉ.',
    );
  } catch (e) {
    print('Đã xảy ra lỗi không mong muốn: $e');
  }
}
