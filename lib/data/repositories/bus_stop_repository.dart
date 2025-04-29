import 'package:busmapcantho/data/datasources/bus_stop_remote_datasource.dart';

import '../model/bus_stop.dart';

class BusStopRepository {
  final BusStopRemoteDatasource _remoteDatasource;
  BusStopRepository([BusStopRemoteDatasource? remoteDatasource])
      : _remoteDatasource = remoteDatasource ?? BusStopRemoteDatasource();

  Future<List<BusStop>> getAllBusStops() {
    return _remoteDatasource.getAllBusStops();
  }

  Future<BusStop?> getBusStopById(String id) {
    return _remoteDatasource.getBusStopById(id);
  }

  Future<List<BusStop>> getBusStopsByRouteId(String routeId) {
    return _remoteDatasource.getBusStopsByRouteId(routeId);
  }

  /*Future<List<BusStop>> getBusStopsByLocation(double latitude, double longitude) {
    return _remoteDatasource.getBusStopsByLocation(latitude, longitude);
  }*/
}