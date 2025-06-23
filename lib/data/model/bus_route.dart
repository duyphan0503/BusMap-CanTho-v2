import 'package:busmapcantho/data/model/route_stop.dart';

class BusRoute {
  final String id;
  final String routeNumber;
  final String routeName;
  final String? description;
  final String? operatingHoursDescription;
  final String? frequencyDescription;
  final String? fareInfo;
  final String? routeType;
  final String? agencyId;
  final String? agencyName; // Added agency name field
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RouteStop> stops;
  Map<String, dynamic>? extra; // For UI-calculated info (not persisted)

  BusRoute({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    this.description,
    this.operatingHoursDescription,
    this.frequencyDescription,
    this.fareInfo,
    this.routeType,
    this.agencyId,
    this.agencyName, // Added to constructor
    required this.createdAt,
    required this.updatedAt,
    this.stops = const [],
    this.extra,
  });

  factory BusRoute.fromJson(
    Map<String, dynamic> json, {
    List<RouteStop>? stops,
  }) {
    return BusRoute(
      id: json['id'] as String,
      routeNumber: json['route_number'] as String,
      routeName: json['route_name'] as String,
      description: json['description'] as String?,
      operatingHoursDescription: json['operating_hours_description'] as String?,
      frequencyDescription: json['frequency_description'] as String?,
      fareInfo: json['fare_info'] as String?,
      routeType: json['route_type'] as String?,
      agencyId: json['agency_id'] as String?,
      agencyName: json['agency_name'] as String?, // Parse agency_name from JSON
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      stops: stops ?? [],
      extra: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'route_number': routeNumber,
    'route_name': routeName,
    'description': description,
    'operating_hours_description': operatingHoursDescription,
    'frequency_description': frequencyDescription,
    'fare_info': fareInfo,
    'route_type': routeType,
    'agency_id': agencyId,
    'agency_name': agencyName, // Include agency name in JSON
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    // Do not serialize extra
  };
}
