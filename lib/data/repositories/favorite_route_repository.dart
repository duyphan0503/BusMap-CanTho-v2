import 'package:injectable/injectable.dart';

import '../datasources/favorite_route_remote_datasource.dart';
import '../model/bus_route.dart';

@lazySingleton
class FavoriteRouteRepository {
  final FavoriteRouteRemoteDatasource _remote;

  FavoriteRouteRepository(this._remote);

  Future<void> saveFavoriteRoute(String routeId) {
    return _remote.saveFavoriteRoute(routeId);
  }

  Future<List<BusRoute>> getFavoriteRoutes() {
    return _remote.getFavoriteRoutes();
  }

  Future<void> removeFavoriteRoute(String routeId) {
    return _remote.removeFavoriteRoute(routeId);
  }
}
