class RouteStop {
  final String routeId;
  final String stopId;
  final int? stopOrder;
  final String? estimatedTime;

  RouteStop({
    required this.routeId,
    required this.stopId,
    this.stopOrder,
    this.estimatedTime,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) => RouteStop(
    routeId: json['route_id'] as String,
    stopId: json['stop_id'] as String,
    stopOrder: json['stop_order'] as int?,
    estimatedTime: json['estimated_time'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'route_id': routeId,
    'stop_id': stopId,
    'stop_order': stopOrder,
    'estimated_time': estimatedTime,
  };
}