import 'package:injectable/injectable.dart';

import '../datasources/route_stop_remote_datasource.dart';
import '../model/route_stop.dart';

@lazySingleton
class RouteStopRepository {
  final RouteStopRemoteDatasource _remoteDatasource;

  RouteStopRepository(this._remoteDatasource);

  // Get sequence of stops for a route in a specific direction
  Future<List<RouteStop>> getRouteStops(String routeId, int direction) {
    return _remoteDatasource.getRouteStops(routeId, direction);
  }

  // Get route IDs that serve a specific stop
  Future<List<String>> getRoutesForStop(String stopId) {
    return _remoteDatasource.getRoutesForStop(stopId);
  }
}
