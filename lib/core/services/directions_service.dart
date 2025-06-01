import 'dart:convert';

import 'package:busmapcantho/configs/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@injectable
class DirectionsService {
  Future<DirectionsResult?> getDirections(
    LatLng start,
    LatLng end, {
    String mode = 'car',
  }) async {
    try {
      // Log request for debugging
      debugPrint(
        '📍 Directions request: from ${start.latitude},${start.longitude} to ${end.latitude},${end.longitude} via $mode',
      );

      // Ưu tiên sử dụng GraphHopper
      final graphhopperResult = await _getGraphHopperDirections(
        start,
        end,
        mode,
      );
      if (graphhopperResult != null) {
        debugPrint('✅ GraphHopper directions found');
        return graphhopperResult;
      }

      // Fallback to OSRM if GraphHopper fails
      debugPrint('⚠️ GraphHopper failed, trying OSRM');
      final osrmResult = await _getOsrmDirections(start, end, mode);
      if (osrmResult != null) {
        debugPrint('✅ OSRM directions found');
        return osrmResult;
      }

      debugPrint('❌ No directions found from either service');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting directions: $e');
      // Try OSRM as last resort
      return await _getOsrmDirections(start, end, mode);
    }
  }

  Future<DirectionsResult?> _getGraphHopperDirections(
    LatLng start,
    LatLng end,
    String mode,
  ) async {
    // Map app mode to GraphHopper vehicle
    // Cấu hình cho từng phương tiện
    final config = _getGraphHopperConfig(mode);
    String vehicle = config['vehicle'] as String;
    Map<String, String> optimizationParams =
        config['params'] as Map<String, String>;

    // Sửa lại queryParams - phải có 2 points riêng biệt với tọa độ đúng
    final points = [
      '${start.latitude},${start.longitude}',
      '${end.latitude},${end.longitude}',
    ];

    final queryParams = {
      'points_encoded': 'false',
      'vehicle': vehicle,
      'locale': 'vi',
      'instructions': 'true',
      'elevation': 'true',
      'key': graphhopperApiKey,
      ...optimizationParams,
    };

    final queryString = [
      for (final entry in queryParams.entries)
        '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
      for (final point in points)
        'point=${Uri.encodeQueryComponent(point)}',
    ].join('&');

    final url = Uri.parse('$graphhopperBaseUrl?$queryString');

    debugPrint('🌐 GraphHopper URL: $url');

    try {
      final resp = await http.get(url);

      if (resp.statusCode != 200) {
        debugPrint('⚠️ GraphHopper error: ${resp.body}');
        return null;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if ((data['paths'] as List).isEmpty) {
        debugPrint('⚠️ GraphHopper returned no paths');
        return null;
      }

      // Lấy đường đi tối ưu nhất
      final path = data['paths'][0];

      // Parse coordinates from points
      final points =
          (path['points']['coordinates'] as List)
              .map<LatLng>((p) => LatLng(p[1] as double, p[0] as double))
              .toList();

      // Parse detailed instructions
      final instructions =
          (path['instructions'] as List?)?.map<Map<String, dynamic>>((
            instruction,
          ) {
            // Thêm vị trí thực tế của điểm instruction trên bản đồ
            LatLng? locationPoint;
            if (instruction['interval'] != null &&
                instruction['interval'] is List &&
                (instruction['interval'] as List).length == 2) {
              final pointIndex = (instruction['interval'] as List)[0];
              if (pointIndex is int && pointIndex < points.length) {
                locationPoint = points[pointIndex];
              }
            }

            // Determine maneuver type and icon type
            final int sign = instruction['sign'] ?? 0;
            final directionIcon = _getDirectionIconFromSign(sign);
            final String streetName = instruction['street_name'] ?? '';

            return {
              'instruction': instruction['text'] ?? '',
              'distance': instruction['distance'] ?? 0,
              'duration': instruction['time'] / 1000,
              // Convert to seconds
              'sign': sign,
              'street_name': streetName,
              'exit_number': instruction['exit_number'],
              'location': locationPoint,
              'heading': instruction['heading'],
              // Direction to head in degrees
              'icon_type': directionIcon.iconType,
              // Add standardized icon type
              'icon_color': directionIcon.colorType,
              // Add standardized icon color type
            };
          }).toList();

      // Tính toán thêm thông tin hữu ích dựa trên phương tiện
      final transportInfo = _calculateTransportInfo(
        mode,
        double.parse(path['distance'].toString()),
        double.parse(path['time'].toString()) / 1000,
      );

      return DirectionsResult(
        polyline: points,
        distanceText: path['distance'].toString(),
        durationText: (path['time'] / 1000).toString(),
        steps: instructions,
        transportInfo: transportInfo,
        transportMode: mode,
        hasElevation: path['ascend'] != null || path['descend'] != null,
        ascend: path['ascend'],
        descend: path['descend'],
      );
    } catch (e) {
      debugPrint('❌ GraphHopper error: $e');
      return null;
    }
  }

  Future<DirectionsResult?> _getOsrmDirections(
    LatLng start,
    LatLng end,
    String mode,
  ) async {
    // Ánh xạ mode từ ứng dụng tới OSRM profile
    String profile;
    Map<String, String> optimizationParams = {};

    switch (mode) {
      case 'car':
        profile = 'driving';
        optimizationParams = {
          'alternatives': 'true',
          'steps': 'true',
          'annotations': 'true',
          'overview': 'full',
          'geometries': 'geojson',
        };
        break;
      case 'walk':
        profile = 'foot';
        optimizationParams = {
          'steps': 'true',
          'annotations': 'true',
          'overview': 'full',
          'geometries': 'geojson',
        };
        break;
      case 'motorbike':
        profile = 'bike'; // OSRM không có motorcycle
        optimizationParams = {
          'steps': 'true',
          'annotations': 'true',
          'overview': 'full',
          'geometries': 'geojson',
        };
        break;
      case 'bus':
        profile = 'driving'; // OSRM không có bus
        optimizationParams = {
          'steps': 'true',
          'annotations': 'true',
          'overview': 'full',
          'geometries': 'geojson',
        };
        break;
      default:
        profile = 'driving';
        optimizationParams = {
          'steps': 'true',
          'overview': 'full',
          'geometries': 'geojson',
        };
    }

    final baseUrl =
        '$osrmBaseUrl/$profile/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}';

    String urlStr = baseUrl;
    if (optimizationParams.isNotEmpty) {
      urlStr += '?';
      optimizationParams.forEach((key, value) {
        urlStr += '$key=$value&';
      });
      urlStr = urlStr.substring(0, urlStr.length - 1);
    }

    final url = Uri.parse(urlStr);
    debugPrint('🌐 OSRM URL: $url');

    try {
      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        debugPrint('⚠️ OSRM error: ${resp.statusCode}');
        return null;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if ((data['routes'] as List).isEmpty) {
        debugPrint('⚠️ OSRM returned no routes');
        return null;
      }

      final coords =
          (data['routes'][0]['geometry']['coordinates'] as List)
              .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
              .toList();

      final leg = (data['routes'][0]['legs'] as List).first;

      final steps =
          (leg['steps'] as List?)?.map<Map<String, dynamic>>((s) {
            final maneuverType = s['maneuver']?['type'] ?? '';
            final maneuverModifier = s['maneuver']?['modifier'];
            final streetName = s['name'] ?? '';

            // Tính vị trí thực tế
            LatLng? locationPoint;
            if (s['maneuver']?['location'] != null) {
              final location = s['maneuver']['location'] as List;
              locationPoint = LatLng(location[1], location[0]);
            }

            // Get instruction text
            final instructionText = _getDetailedOsrmInstructionText(
              maneuverType,
              maneuverModifier,
              streetName,
            );

            // Determine icon type based on maneuver type and modifier
            final directionIcon = _getDirectionIconFromOsrm(
              maneuverType,
              maneuverModifier,
            );

            return {
              'instruction': instructionText,
              'distance': s['distance'],
              'duration': s['duration'],
              'street_name': streetName,
              'location': locationPoint,
              'heading': s['maneuver']?['bearing_after'],
              'icon_type': directionIcon.iconType,
              // Add standardized icon type
              'icon_color': directionIcon.colorType,
              // Add standardized icon color type
              'maneuver_type': maneuverType,
              // Keep original type for debugging
              'maneuver_modifier': maneuverModifier,
              // Keep original modifier for debugging
            };
          }).toList();

      // Tính toán thêm thông tin hữu ích dựa trên phương tiện
      final transportInfo = _calculateTransportInfo(
        mode,
        leg['distance'],
        leg['duration'],
      );

      return DirectionsResult(
        polyline: coords,
        distanceText: leg['distance'].toString(),
        durationText: leg['duration'].toString(),
        steps: steps,
        transportInfo: transportInfo,
        transportMode: mode,
      );
    } catch (e) {
      debugPrint('❌ OSRM error: $e');
      return null;
    }
  }

  // Trả về các tham số tối ưu cho từng phương tiện trên GraphHopper
  Map<String, dynamic> _getGraphHopperConfig(String mode) {
    switch (mode) {
      case 'car':
        return {
          'vehicle': 'car',
          'params': {
            'weighting': 'fastest',
            'ch.disable': 'true',
            'algorithm': 'alternative_route',
            'alternative_route.max_paths': '2',
            'alternative_route.max_weight_factor': '1.4',
            'avoid': 'toll,ferry',
          },
        };
      case 'walk':
        return {
          'vehicle': 'foot',
          'params': {
            'weighting': 'shortest',
            'elevation': 'true',
            'algorithm': 'astar',
            'ch.disable': 'true',
          },
        };
      case 'motorbike':
        return {
          'vehicle': 'motorcycle',
          'params': {
            'weighting': 'fastest',
            'ch.disable': 'true',
            'avoid': 'toll,unpavedroads',
            'algorithm': 'astar',
          },
        };
      case 'bus':
        return {
          'vehicle': 'bus',
          'params': {
            'weighting': 'fastest',
            'ch.disable': 'true',
            'avoid': 'unpavedroads',
            'algorithm': 'astar',
          },
        };
      default:
        return {
          'vehicle': 'car',
          'params': {'weighting': 'fastest', 'ch.disable': 'true'},
        };
    }
  }

  // Tạo thông tin bổ sung dựa trên phương tiện
  Map<String, dynamic> _calculateTransportInfo(
    String mode,
    double distance,
    double duration,
  ) {
    switch (mode) {
      case 'car':
        final fuelConsumption = distance / 1000 * 0.07; // Lít/km
        final co2Emission = distance / 1000 * 120; // g/km
        return {
          'fuel_consumption': fuelConsumption.toStringAsFixed(2),
          'co2_emission': co2Emission.toStringAsFixed(0),
          'avg_speed': (distance / duration * 3.6).toStringAsFixed(1),
        };
      case 'walk':
        final calories = distance / 1000 * 65; // Calo/km
        return {
          'calories': calories.toStringAsFixed(0),
          'steps': (distance * 1.31).toStringAsFixed(0),
          'health_index': 'high',
        };
      case 'motorbike':
        final fuelConsumption = distance / 1000 * 0.03; // L��t/km
        final co2Emission = distance / 1000 * 80; // g/km
        return {
          'fuel_consumption': fuelConsumption.toStringAsFixed(2),
          'co2_emission': co2Emission.toStringAsFixed(0),
          'avg_speed': (distance / duration * 3.6).toStringAsFixed(1),
        };
      case 'bus':
        final co2Emission = distance / 1000 * 30; // g/km (per passenger)
        return {
          'cost_estimate': (distance / 1000 * 5000).toStringAsFixed(0),
          'co2_emission': co2Emission.toStringAsFixed(0),
          'health_index': 'medium',
          'passenger_count': '20-30',
        };
      default:
        return {};
    }
  }

  // Cải thiện văn bản hướng dẫn từ OSRM
  String _getDetailedOsrmInstructionText(
    String type,
    String? modifier,
    String streetName,
  ) {
    String instruction = '';
    final road = streetName.isNotEmpty ? ' vào $streetName' : '';

    switch (type) {
      case 'turn':
        if (modifier == 'left') {
          instruction = 'Rẽ trái$road';
        } else if (modifier == 'right') {
          instruction = 'Rẽ phải$road';
        } else if (modifier == 'straight') {
          instruction = 'Đi thẳng$road';
        } else if (modifier?.contains('slight') == true) {
          instruction =
              modifier?.contains('left') == true
                  ? 'Rẽ nhẹ sang trái$road'
                  : 'Rẽ nhẹ sang phải$road';
        } else if (modifier?.contains('sharp') == true) {
          instruction =
              modifier?.contains('left') == true
                  ? 'Rẽ gắt sang trái$road'
                  : 'Rẽ gắt sang phải$road';
        } else if (modifier == 'uturn') {
          instruction = 'Quay đầu xe$road';
        }
        break;
      case 'new name':
        instruction = 'Tiếp tục đi trên $streetName';
        break;
      case 'depart':
        instruction = 'Bắt đầu hành trình$road';
        break;
      case 'arrive':
        instruction = 'Đến điểm đích';
        break;
      case 'roundabout':
      case 'rotary':
        instruction =
            'Đi vào vòng xoay${modifier != null ? ' và ra ở lối ra thứ $modifier' : ''}$road';
        break;
      case 'merge':
        instruction = 'Nhập vào đường$road';
        break;
      case 'fork':
        if (modifier == 'left') {
          instruction = 'Đi theo lối rẽ trái$road';
        } else if (modifier == 'right') {
          instruction = 'Đi theo lối rẽ phải$road';
        } else {
          instruction = 'Giữ làn đường$road';
        }
        break;
      case 'end of road':
        instruction =
            'Đi đến cuối đường rồi ${modifier == 'left' ? 'rẽ trái' : 'rẽ phải'}$road';
        break;
      default:
        instruction = 'Tiếp tục hành trình$road';
    }

    return instruction;
  }

  // Add new methods to standardize icon selection
  _DirectionIconInfo _getDirectionIconFromSign(int sign) {
    switch (sign) {
      case -98: // Destination
        return _DirectionIconInfo(
          DirectionIconType.place,
          DirectionIconColorType.destination,
        );
      case -8: // Left
        return _DirectionIconInfo(
          DirectionIconType.turnLeft,
          DirectionIconColorType.turn,
        );
      case -7: // Right
        return _DirectionIconInfo(
          DirectionIconType.turnRight,
          DirectionIconColorType.turn,
        );
      case -3: // Sharp left
        return _DirectionIconInfo(
          DirectionIconType.turnSlightLeft,
          DirectionIconColorType.turn,
        );
      case -2: // Sharp right
        return _DirectionIconInfo(
          DirectionIconType.turnSlightRight,
          DirectionIconColorType.turn,
        );
      case -1: // Slight left
        return _DirectionIconInfo(
          DirectionIconType.turnSlightLeft,
          DirectionIconColorType.turn,
        );
      case 1: // Slight right
        return _DirectionIconInfo(
          DirectionIconType.turnSlightRight,
          DirectionIconColorType.turn,
        );
      case 2: // Straight
        return _DirectionIconInfo(
          DirectionIconType.straight,
          DirectionIconColorType.straight,
        );
      case 3: // Roundabout
        return _DirectionIconInfo(
          DirectionIconType.roundabout,
          DirectionIconColorType.special,
        );
      case 4: // Arrived
        return _DirectionIconInfo(
          DirectionIconType.place,
          DirectionIconColorType.destination,
        );
      case 5: // Keep left
        return _DirectionIconInfo(
          DirectionIconType.forkLeft,
          DirectionIconColorType.special,
        );
      case 6: // Keep right
        return _DirectionIconInfo(
          DirectionIconType.forkRight,
          DirectionIconColorType.special,
        );
      case 7: // U-turn
        return _DirectionIconInfo(
          DirectionIconType.uTurn,
          DirectionIconColorType.special,
        );
      default:
        return _DirectionIconInfo(
          DirectionIconType.continue_,
          DirectionIconColorType.straight,
        );
    }
  }

  _DirectionIconInfo _getDirectionIconFromOsrm(String type, String? modifier) {
    if (type == 'turn') {
      if (modifier == 'left') {
        return _DirectionIconInfo(
          DirectionIconType.turnLeft,
          DirectionIconColorType.turn,
        );
      } else if (modifier == 'right') {
        return _DirectionIconInfo(
          DirectionIconType.turnRight,
          DirectionIconColorType.turn,
        );
      } else if (modifier == 'straight') {
        return _DirectionIconInfo(
          DirectionIconType.straight,
          DirectionIconColorType.straight,
        );
      } else if (modifier?.contains('slight') == true &&
          modifier?.contains('left') == true) {
        return _DirectionIconInfo(
          DirectionIconType.turnSlightLeft,
          DirectionIconColorType.turn,
        );
      } else if (modifier?.contains('slight') == true &&
          modifier?.contains('right') == true) {
        return _DirectionIconInfo(
          DirectionIconType.turnSlightRight,
          DirectionIconColorType.turn,
        );
      } else if (modifier?.contains('sharp') == true &&
          modifier?.contains('left') == true) {
        return _DirectionIconInfo(
          DirectionIconType.turnSlightLeft,
          DirectionIconColorType.turn,
        );
      } else if (modifier?.contains('sharp') == true &&
          modifier?.contains('right') == true) {
        return _DirectionIconInfo(
          DirectionIconType.turnSlightRight,
          DirectionIconColorType.turn,
        );
      } else if (modifier == 'uturn') {
        return _DirectionIconInfo(
          DirectionIconType.uTurn,
          DirectionIconColorType.special,
        );
      }
    } else if (type == 'depart') {
      return _DirectionIconInfo(
        DirectionIconType.start,
        DirectionIconColorType.start,
      );
    } else if (type == 'arrive') {
      return _DirectionIconInfo(
        DirectionIconType.place,
        DirectionIconColorType.destination,
      );
    } else if (type == 'roundabout' || type == 'rotary') {
      return _DirectionIconInfo(
        DirectionIconType.roundabout,
        DirectionIconColorType.special,
      );
    } else if (type == 'merge') {
      return _DirectionIconInfo(
        DirectionIconType.merge,
        DirectionIconColorType.special,
      );
    } else if (type == 'fork') {
      if (modifier == 'left') {
        return _DirectionIconInfo(
          DirectionIconType.forkLeft,
          DirectionIconColorType.special,
        );
      } else if (modifier == 'right') {
        return _DirectionIconInfo(
          DirectionIconType.forkRight,
          DirectionIconColorType.special,
        );
      }
    } else if (type == 'end of road') {
      if (modifier == 'left') {
        return _DirectionIconInfo(
          DirectionIconType.turnLeft,
          DirectionIconColorType.turn,
        );
      } else if (modifier == 'right') {
        return _DirectionIconInfo(
          DirectionIconType.turnRight,
          DirectionIconColorType.turn,
        );
      }
    }
    return _DirectionIconInfo(
      DirectionIconType.continue_,
      DirectionIconColorType.straight,
    );
  }
}

class DirectionsResult {
  final List<LatLng> polyline;
  final String distanceText;
  final String durationText;
  final List<Map<String, dynamic>>? steps;
  final Map<String, dynamic> transportInfo;
  final String transportMode;
  final bool hasElevation;
  final double? ascend;
  final double? descend;

  DirectionsResult({
    required this.polyline,
    required this.distanceText,
    required this.durationText,
    this.steps,
    this.transportInfo = const {},
    this.transportMode = 'car',
    this.hasElevation = false,
    this.ascend,
    this.descend,
  });

  // Hàm tiện ích để lấy thông tin rõ ràng
  String get formattedDistance {
    final distance = double.parse(distanceText);
    return distance >= 1000
        ? '${(distance / 1000).toStringAsFixed(1)} km'
        : '${distance.toStringAsFixed(0)} m';
  }

  String get formattedDuration {
    final duration = double.parse(durationText);
    final hours = (duration / 3600).floor();
    final minutes = ((duration % 3600) / 60).ceil();

    if (hours > 0) {
      return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
    } else {
      return '$minutes phút';
    }
  }
}

// Define standardized enum for direction icon types
enum DirectionIconType {
  turnLeft,
  turnRight,
  turnSlightLeft,
  turnSlightRight,
  straight,
  roundabout,
  place,
  forkLeft,
  forkRight,
  uTurn,
  start,
  merge,
  exit,
  continue_,
}

// Define standardized enum for icon colors
enum DirectionIconColorType {
  turn,
  straight,
  special,
  destination,
  start,
  default_,
}

class _DirectionIconInfo {
  final DirectionIconType iconType;
  final DirectionIconColorType colorType;

  _DirectionIconInfo(this.iconType, this.colorType);
}
