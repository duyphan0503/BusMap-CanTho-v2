import 'package:injectable/injectable.dart';

import '../datasources/bus_route_remote_datasource.dart';
import '../model/bus_route.dart';

@lazySingleton
class BusRouteRepository {
  final BusRouteRemoteDatasource _remoteDatasource;

  BusRouteRepository(this._remoteDatasource);

  Future<List<BusRoute>> getAllBusRoutes() {
    return _remoteDatasource.getBusRoutes();
  }

  Future<BusRoute?> getBusRouteById(String id) async {
    try {
      return await _remoteDatasource.getBusRouteById(id);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<BusRoute>> searchBusRoutes(String query) {
    return _remoteDatasource.searchBusRoutes(query);
  }

  // Admin-only methods
  Future<void> addBusRoute(BusRoute route) async {
    // Implementation depends on your admin API
    throw UnimplementedError('Admin functionality not implemented');
  }

  Future<void> updateBusRoute(BusRoute route) async {
    // Implementation depends on your admin API
    throw UnimplementedError('Admin functionality not implemented');
  }

  Future<void> deleteBusRoute(String id) async {
    // Implementation depends on your admin API
    throw UnimplementedError('Admin functionality not implemented');
  }
}
