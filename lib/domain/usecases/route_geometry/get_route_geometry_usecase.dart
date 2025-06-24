import 'package:busmapcantho/core/services/osrm_routing_service.dart';
import 'package:busmapcantho/domain/usecases/route_stops/get_route_stops_as_bus_stops_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

/// UseCase to fetch route geometry that follows actual roads between bus stops
@lazySingleton
class GetRouteGeometryUseCase {
  final OsrmRoutingService _routingService;
  final GetRouteStopsAsBusStopsUseCase _getRouteStopsUseCase;
  final Logger _logger;

  /// Create a new instance of [GetRouteGeometryUseCase]
  GetRouteGeometryUseCase(
    this._routingService,
    this._getRouteStopsUseCase,
    this._logger,
  );

  /// Fetches a route geometry that follows actual roads
  ///
  /// [routeId] - ID of the bus route
  /// [direction] - Direction of travel (0 for outbound, 1 for inbound)
  /// Returns a list of LatLng points representing the actual route path
  Future<List<LatLng>> call(String routeId, int direction) async {
    try {
      // Get the stops for this route and direction
      final stops = await _getRouteStopsUseCase(routeId, direction);

      if (stops.isEmpty || stops.length < 2) {
        _logger.w('Route $routeId direction $direction has less than 2 stops');
        return [];
      }

      // Convert stops to LatLng points
      final waypoints =
          stops.map((stop) => LatLng(stop.latitude, stop.longitude)).toList();

      // Fetch the route geometry from OSRM
      final routeGeometry = await _routingService.fetchReverseRouteGeometry(
        waypoints,
        profile: 'driving', // Use driving profile for buses
      );

      return routeGeometry;
    } catch (e, stack) {
      _logger.e('Failed to get route geometry: $e', stackTrace: stack);
      return [];
    }
  }
}
