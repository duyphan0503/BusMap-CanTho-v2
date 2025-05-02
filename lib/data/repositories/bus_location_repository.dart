import 'package:injectable/injectable.dart';

import '../datasources/bus_location_remote_datasource.dart';
import '../model/bus_location.dart';

@lazySingleton
class BusLocationRepository {
  final BusLocationRemoteDatasource _remoteDatasource;

  BusLocationRepository(this._remoteDatasource);

  // Get real-time bus locations for a specific route
  Future<List<BusLocation>> getBusLocationsByRouteId(String routeId) {
    return _remoteDatasource.getBusLocationsByRouteId(routeId);
  }

  // Subscribe to real-time updates for bus locations on a specific route
  Stream<List<BusLocation>> subscribeToBusLocations(String routeId) {
    return _remoteDatasource.subscribeToBusLocations(routeId);
  }

  // Update bus location (for GPS transmitters only)
  Future<void> updateBusLocation(BusLocation busLocation) {
    return _remoteDatasource.updateBusLocation(busLocation);
  }
}
