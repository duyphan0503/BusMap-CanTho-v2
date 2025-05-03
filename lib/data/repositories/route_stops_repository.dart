import 'package:injectable/injectable.dart';

import '../datasources/route_stop_remote_datasource.dart';
import '../model/bus_stop.dart';
import '../model/route_stop.dart';

@lazySingleton
class RouteStopsRepository {
  final RouteStopRemoteDatasource _remoteDatasource;

  RouteStopsRepository(this._remoteDatasource);

  Future<List<RouteStop>> getRouteStops(String routeId, int direction) {
    return _remoteDatasource.getRouteStops(routeId, direction);
  }

  Future<List<BusStop>> getRouteStopsAsBusStops(String routeId, int direction) async {
    final routeStops = await _remoteDatasource.getRouteStops(routeId, direction);
    return routeStops.map((routeStop) => routeStop.stop).toList();
  }

  Future<List<String>> getRoutesForStop(String stopId) {
    return _remoteDatasource.getRoutesForStop(stopId);
  }
}
