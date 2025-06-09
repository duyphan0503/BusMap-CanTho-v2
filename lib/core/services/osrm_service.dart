import 'dart:convert';

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
      String profile;
      Map<String, String> params = {
        'steps': 'true',
        'overview': 'full',
        'geometries': 'geojson',
      };

      switch (mode) {
        case 'car':
          profile = 'driving';
          break;
        case 'walk':
          profile = 'foot';
          break;
        case 'bike':
          profile = 'bike';
          break;
        default:
          profile = 'driving';
      }

      final url = Uri.parse(
        '$osrmBaseUrl/$profile/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}',
      );

      final resp = await http.get(url);
      if (resp.statusCode != 200) return null;

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final routes = data['routes'] as List;
      if (routes.isEmpty) return null;

      final coords =
          (routes[0]['geometry']['coordinates'] as List)
              .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
              .toList();

      final leg = routes[0]['legs'][0];
      double distance = leg['distance'].toDouble();
      double duration = leg['duration'].toDouble();

      final adjusted = _applyTransportAdjustments(
        mode,
        distance,
        duration,
        coords.length,
      );
      distance = adjusted.distance;
      duration = adjusted.duration;

      final steps =
          (leg['steps'] as List?)?.map<Map<String, dynamic>>((s) {
            final maneuver = s['maneuver'];
            final type = maneuver['type'] ?? '';
            final modifier = maneuver['modifier'];
            final streetName = s['name'] ?? '';

            final instruction = _getDetailedOsrmInstructionText(
              type,
              modifier,
              streetName,
            );
            final iconInfo = _getDirectionIconFromOsrm(type, modifier);

            final location =
                maneuver['location'] != null
                    ? LatLng(maneuver['location'][1], maneuver['location'][0])
                    : null;

            return {
              'instruction': instruction,
              'distance': s['distance'] * adjusted.distanceRatio,
              'duration': s['duration'] * adjusted.durationRatio,
              'street_name': streetName,
              'location': location,
              'heading': maneuver['bearing_after'],
              'icon_type': iconInfo.iconType,
              'icon_color': iconInfo.colorType,
              'maneuver_type': type,
              'maneuver_modifier': modifier,
            };
          }).toList();

      final transportInfo = _calculateTransportInfo(mode, distance, duration);

      return DirectionsResult(
        polyline: coords,
        distanceText: distance.toString(),
        durationText: duration.toString(),
        steps: steps,
        transportInfo: transportInfo,
        transportMode: mode,
      );
    } catch (e) {
      return null;
    }
  }

  String _getDetailedOsrmInstructionText(
    String type,
    String? modifier,
    String streetName,
  ) {
    final road = streetName.isNotEmpty ? ' vào $streetName' : '';
    switch (type) {
      case 'turn':
        if (modifier == 'left') return 'Rẽ trái$road';
        if (modifier == 'right') return 'Rẽ phải$road';
        if (modifier == 'straight') return 'Đi thẳng$road';
        if (modifier?.contains('slight') ?? false) {
          return modifier!.contains('left')
              ? 'Rẽ nhẹ sang trái$road'
              : 'Rẽ nhẹ sang phải$road';
        }
        if (modifier?.contains('sharp') ?? false) {
          return modifier!.contains('left')
              ? 'Rẽ gắt sang trái$road'
              : 'Rẽ gắt sang phải$road';
        }
        if (modifier == 'uturn') return 'Quay đầu xe$road';
        break;
      case 'new name':
        return 'Tiếp tục đi trên $streetName';
      case 'depart':
        return 'Bắt đầu hành trình$road';
      case 'arrive':
        return 'Đến điểm đích';
      case 'roundabout':
      case 'rotary':
        return 'Đi vào vòng xoay${modifier != null ? ' và ra ở lối ra thứ $modifier' : ''}$road';
      case 'merge':
        return 'Nhập vào đường$road';
      case 'fork':
        if (modifier == 'left') return 'Đi theo lối rẽ trái$road';
        if (modifier == 'right') return 'Đi theo lối rẽ phải$road';
        return 'Giữ làn đường$road';
      case 'end of road':
        return 'Đi đến cuối đường rồi ${modifier == 'left' ? 'rẽ trái' : 'rẽ phải'}$road';
      default:
        return 'Tiếp tục hành trình$road';
    }
    return 'Tiếp tục hành trình$road';
  }

  _DirectionIconInfo _getDirectionIconFromOsrm(String type, String? modifier) {
    switch (type) {
      case 'turn':
        if (modifier == 'left') {
          return _DirectionIconInfo(
            DirectionIconType.turnLeft,
            DirectionIconColorType.turn,
          );
        }
        if (modifier == 'right') {
          return _DirectionIconInfo(
            DirectionIconType.turnRight,
            DirectionIconColorType.turn,
          );
        }
        if (modifier == 'straight') {
          return _DirectionIconInfo(
            DirectionIconType.straight,
            DirectionIconColorType.straight,
          );
        }
        if (modifier?.contains('slight') ?? false) {
          return modifier!.contains('left')
              ? _DirectionIconInfo(
                DirectionIconType.turnSlightLeft,
                DirectionIconColorType.turn,
              )
              : _DirectionIconInfo(
                DirectionIconType.turnSlightRight,
                DirectionIconColorType.turn,
              );
        }
        if (modifier?.contains('sharp') ?? false) {
          return modifier!.contains('left')
              ? _DirectionIconInfo(
                DirectionIconType.turnSlightLeft,
                DirectionIconColorType.turn,
              )
              : _DirectionIconInfo(
                DirectionIconType.turnSlightRight,
                DirectionIconColorType.turn,
              );
        }
        if (modifier == 'uturn') {
          return _DirectionIconInfo(
            DirectionIconType.uTurn,
            DirectionIconColorType.special,
          );
        }
        break;
      case 'depart':
        return _DirectionIconInfo(
          DirectionIconType.start,
          DirectionIconColorType.start,
        );
      case 'arrive':
        return _DirectionIconInfo(
          DirectionIconType.place,
          DirectionIconColorType.destination,
        );
      case 'roundabout':
      case 'rotary':
        return _DirectionIconInfo(
          DirectionIconType.roundabout,
          DirectionIconColorType.special,
        );
      case 'merge':
        return _DirectionIconInfo(
          DirectionIconType.merge,
          DirectionIconColorType.special,
        );
      case 'fork':
        if (modifier == 'left') {
          return _DirectionIconInfo(
            DirectionIconType.forkLeft,
            DirectionIconColorType.special,
          );
        }
        if (modifier == 'right') {
          return _DirectionIconInfo(
            DirectionIconType.forkRight,
            DirectionIconColorType.special,
          );
        }
        break;
      case 'end of road':
        if (modifier == 'left') {
          return _DirectionIconInfo(
            DirectionIconType.turnLeft,
            DirectionIconColorType.turn,
          );
        }
        if (modifier == 'right') {
          return _DirectionIconInfo(
            DirectionIconType.turnRight,
            DirectionIconColorType.turn,
          );
        }
        break;
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
        return {
          'fuel_consumption': (distance / 1000 * 0.07).toStringAsFixed(2),
          'co2_emission': (distance / 1000 * 120).toStringAsFixed(0),
          'avg_speed': (distance / duration * 3.6).toStringAsFixed(1),
        };
      case 'walk':
        return {
          'calories': (distance / 1000 * 65).toStringAsFixed(0),
          'steps': (distance * 1.31).toStringAsFixed(0),
          'health_index': 'high',
        };
      case 'bike':
        return {
          'fuel_consumption': (distance / 1000 * 0.03).toStringAsFixed(2),
          'co2_emission': (distance / 1000 * 80).toStringAsFixed(0),
          'avg_speed': (distance / duration * 3.6).toStringAsFixed(1),
        };
      case 'bus':
        return {
          'cost_estimate': (distance / 1000 * 5000).toStringAsFixed(0),
          'co2_emission': (distance / 1000 * 30).toStringAsFixed(0),
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
    double distanceRatio = 1.0;
    double durationRatio = 1.0;

    if (mode == 'walk') {
      distanceRatio = 0.95;
      durationRatio = 4.5;
    } else if (mode == 'bike') {
      durationRatio = 1.15;
    }

    double adjustedDistance = distance * distanceRatio;
    double adjustedDuration = duration * durationRatio;

    if (waypointCount > 10) {
      adjustedDuration *= 1.0 + (waypointCount - 10) * 0.01;
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
    return hours > 0
        ? '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}'
        : '$minutes phút';
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
