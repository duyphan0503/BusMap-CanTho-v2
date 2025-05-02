import 'bus_stop.dart';

class RouteStop {
  final String id;
  final String routeId;
  final BusStop stop;
  final int sequence;
  final int direction;
  final DateTime createdAt;
  final DateTime updatedAt;

  RouteStop({
    required this.id,
    required this.routeId,
    required this.stop,
    required this.sequence,
    required this.direction,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RouteStop.fromJson(
      Map<String, dynamic> json,
      BusStop stop,
      ) {
    return RouteStop(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      stop: stop,
      sequence: json['sequence'] as int,
      direction: json['direction'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'route_id': routeId,
    'stop_id': stop.id,
    'sequence': sequence,
    'direction': direction,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
