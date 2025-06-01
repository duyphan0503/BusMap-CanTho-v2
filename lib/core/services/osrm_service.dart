import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../configs/env.dart';

@injectable
class OsrmService {
  Future<DirectionsResult?> getDirections(
      LatLng start,
      LatLng end, {
        String mode = 'car',
      }) async {
    try {
      debugPrint(
        '📍 OSRM request: from ${start.latitude},${start.longitude} to ${end.latitude},${end.longitude} via $mode',
      );

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
          profile = 'bike';
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

      double baseDistance = leg['distance'].toDouble();
      double baseDuration = leg['duration'].toDouble();

      final adjustedValues = _applyTransportAdjustments(
        mode,
        baseDistance,
        baseDuration,
        coords.length,
      );

      final steps =
          (leg['steps'] as List?)?.map<Map<String, dynamic>>((s) {
            final maneuverType = s['maneuver']?['type'] ?? '';
            final maneuverModifier = s['maneuver']?['modifier'];
            final streetName = s['name'] ?? '';

            LatLng? locationPoint;
            if (s['maneuver']?['location'] != null) {
              final location = s['maneuver']['location'] as List;
              locationPoint = LatLng(location[1], location[0]);
            }

            final instructionText = _getDetailedOsrmInstructionText(
              maneuverType,
              maneuverModifier,
              streetName,
            );

            final directionIcon = _getDirectionIconFromOsrm(
              maneuverType,
              maneuverModifier,
            );

            double stepDistance = s['distance'].toDouble();
            double stepDuration = s['duration'].toDouble();

            if (adjustedValues.distanceRatio != 1.0 ||
                adjustedValues.durationRatio != 1.0) {
              stepDistance *= adjustedValues.distanceRatio;
              stepDuration *= adjustedValues.durationRatio;
            }

            return {
              'instruction': instructionText,
              'distance': stepDistance,
              'duration': stepDuration,
              'street_name': streetName,
              'location': locationPoint,
              'heading': s['maneuver']?['bearing_after'],
              'icon_type': directionIcon.iconType,
              'icon_color': directionIcon.colorType,
              'maneuver_type': maneuverType,
              'maneuver_modifier': maneuverModifier,
            };
          }).toList();

      final transportInfo = _calculateTransportInfo(
        mode,
        adjustedValues.distance,
        adjustedValues.duration,
      );

      return DirectionsResult(
        polyline: coords,
        distanceText: adjustedValues.distance.toString(),
        durationText: adjustedValues.duration.toString(),
        steps: steps,
        transportInfo: transportInfo,
        transportMode: mode,
      );
    } catch (e) {
      debugPrint('❌ OSRM error: $e');
      return null;
    }
  }

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

  Map<String, dynamic> _calculateTransportInfo(
    String mode,
    double distance,
    double duration,
  ) {
    switch (mode) {
      case 'car':
        final fuelConsumption = distance / 1000 * 0.07;
        final co2Emission = distance / 1000 * 120;
        return {
          'fuel_consumption': fuelConsumption.toStringAsFixed(2),
          'co2_emission': co2Emission.toStringAsFixed(0),
          'avg_speed': (distance / duration * 3.6).toStringAsFixed(1),
        };
      case 'walk':
        final calories = distance / 1000 * 65;
        return {
          'calories': calories.toStringAsFixed(0),
          'steps': (distance * 1.31).toStringAsFixed(0),
          'health_index': 'high',
        };
      case 'motorbike':
        final fuelConsumption = distance / 1000 * 0.03;
        final co2Emission = distance / 1000 * 80;
        return {
          'fuel_consumption': fuelConsumption.toStringAsFixed(2),
          'co2_emission': co2Emission.toStringAsFixed(0),
          'avg_speed': (distance / duration * 3.6).toStringAsFixed(1),
        };
      case 'bus':
        final co2Emission = distance / 1000 * 30;
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

  _TransportAdjustment _applyTransportAdjustments(
    String mode,
    double distance,
    double duration,
    int waypointCount,
  ) {
    double adjustedDistance = distance;
    double adjustedDuration = duration;
    double distanceRatio = 1.0;
    double durationRatio = 1.0;

    switch (mode) {
      case 'car':
        break;

      case 'walk':
        distanceRatio = 0.95;
        durationRatio = 4.5;
        break;

      case 'motorbike':
        distanceRatio = 1.0;
        durationRatio = 1.15;
        break;

      default:
        break;
    }

    adjustedDistance = distance * distanceRatio;
    adjustedDuration = duration * durationRatio;

    if (waypointCount > 10) {
      double complexityFactor = 1.0 + (waypointCount - 10) * 0.01;
      adjustedDuration *= complexityFactor;
    }

    return _TransportAdjustment(
      adjustedDistance,
      adjustedDuration,
      distanceRatio,
      durationRatio,
    );
  }
}

class _TransportAdjustment {
  final double distance;
  final double duration;
  final double distanceRatio;
  final double durationRatio;

  _TransportAdjustment(
    this.distance,
    this.duration,
    this.distanceRatio,
    this.durationRatio,
  );
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
