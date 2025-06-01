import 'package:injectable/injectable.dart';

import '../datasources/route_stop_remote_datasource.dart';
import '../model/bus_stop.dart';
import '../model/route_stop.dart';

@lazySingleton
class RouteStopsRepository {
  final RouteStopRemoteDatasource _remoteDatasource;

  RouteStopsRepository(this._remoteDatasource);

  /// Get all route stops for a specific route and direction
  Future<List<RouteStop>> getRouteStops(String routeId, int direction) {
    return _remoteDatasource.getRouteStops(routeId, direction);
  }

  /// Get all bus stops for a specific route and direction, ordered by sequence
  Future<List<BusStop>> getRouteStopsAsBusStops(String routeId, int direction) async {
    final routeStops = await _remoteDatasource.getRouteStops(routeId, direction);
    return routeStops.map((routeStop) => routeStop.stop).toList();
  }

  /// Get all route IDs that pass through a specific stop
  Future<List<String>> getRoutesForStop(String stopId) {
    return _remoteDatasource.getRoutesForStop(stopId);
  }

  /// Check if a stop is part of a specific route and direction
  Future<bool> isStopOnRoute(String routeId, String stopId, int direction) async {
    final routeStop = await _remoteDatasource.getRouteStop(routeId, stopId, direction);
    return routeStop != null;
  }

  /// Get a specific route stop by route, stop, and direction
  Future<RouteStop?> getRouteStop(String routeId, String stopId, int direction) {
    return _remoteDatasource.getRouteStop(routeId, stopId, direction);
  }

  /// Get the sequence number of a stop within a route
  Future<int?> getStopSequence(String routeId, String stopId, int direction) async {
    final routeStop = await _remoteDatasource.getRouteStop(routeId, stopId, direction);
    return routeStop?.sequence;
  }
}
