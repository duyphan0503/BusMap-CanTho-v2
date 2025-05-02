import 'package:busmapcantho/data/datasources/bus_stop_remote_datasource.dart';
import 'package:busmapcantho/data/datasources/route_stop_remote_datasource.dart';
import 'package:injectable/injectable.dart';

import '../model/bus_stop.dart';

@lazySingleton
class BusStopRepository {
  final BusStopRemoteDatasource _remoteDatasource;
  final RouteStopRemoteDatasource _routeStopDatasource;
  
  BusStopRepository(this._remoteDatasource, this._routeStopDatasource);

  Future<List<BusStop>> getAllBusStops() {
    return _remoteDatasource.getBusStops();
  }

  Future<BusStop?> getBusStopById(String id) async {
    try {
      return await _remoteDatasource.getBusStopById(id);
    } catch (e) {
      return null;
    }
  }

  Future<List<BusStop>> getBusStopsByRouteId(String routeId) async {
    final routeStops = await _routeStopDatasource.getRouteStops(routeId, 0); // Direction 0
    return routeStops.map((routeStop) => routeStop.stop).toList();
  }
  
  Future<List<BusStop>> getBusStopsByRouteIdAndDirection(String routeId, int direction) async {
    final routeStops = await _routeStopDatasource.getRouteStops(routeId, direction);
    return routeStops.map((routeStop) => routeStop.stop).toList();
  }

  Future<List<BusStop>> getNearbyBusStops(double lat, double lng, double radiusInMeters) {
    return _remoteDatasource.getNearbyBusStops(lat, lng, radiusInMeters);
  }
  
  Future<List<BusStop>> searchBusStops(String query) {
    return _remoteDatasource.searchBusStops(query);
  }
}
