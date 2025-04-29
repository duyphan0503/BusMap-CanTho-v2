import '../datasources/bus_route_remote_datasource.dart';
import '../model/bus_route.dart';

class BusRouteRepository {
  final BusRouteRemoteDatasource _remoteDatasource;

  BusRouteRepository([BusRouteRemoteDatasource? remoteDatasource])
    : _remoteDatasource = remoteDatasource ?? BusRouteRemoteDatasource();

  Future<List<BusRoute>> getAllBusRoutes() {
    return _remoteDatasource.getAllBusRoutes();
  }

  Future<BusRoute?> getBusRouteById(String id) {
    return _remoteDatasource.getBusRouteById(id);
  }

  Future<void> addBusRoute(BusRoute route) {
    return _remoteDatasource.addBusRoute(route);
  }

  Future<void> updateBusRoute(BusRoute route) {
    return _remoteDatasource.updateBusRoute(route);
  }

  Future<void> deleteBusRoute(String id) {
    return _remoteDatasource.deleteBusRoute(id);
  }
}