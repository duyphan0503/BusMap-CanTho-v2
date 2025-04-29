import 'package:busmapcantho/data/datasources/favorite_route_remote_datasource.dart';

class FavoriteRouteRepository {
  final FavoriteRouteRemoteDatasource _remoteDatasource;

  FavoriteRouteRepository([FavoriteRouteRemoteDatasource? remoteDatasource])
    : _remoteDatasource = remoteDatasource ?? FavoriteRouteRemoteDatasource();

  Future<void> saveFavoriteRoute(String userId, String routeId) {
    return _remoteDatasource.saveFavoriteRoute(userId, routeId);
  }

  Future<List<String>> getFavoriteRoutes(String userId) {
    return _remoteDatasource.getFavoriteRoutes(userId);
  }

  Future<void> removeFavoriteRoute(String userId, String routeId) {
    return _remoteDatasource.removeFavoriteRoute(userId, routeId);
  }
}