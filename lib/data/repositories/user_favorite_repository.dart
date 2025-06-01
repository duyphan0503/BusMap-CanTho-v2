import 'package:injectable/injectable.dart';

import '../datasources/user_favorite_remote_datasource.dart';
import '../model/user_favorite.dart';

@lazySingleton
class UserFavoriteRepository {
  final UserFavoriteRemoteDatasource _remoteDatasource;

  UserFavoriteRepository(this._remoteDatasource);

  // Get all favorite stops for the current authenticated user
  Future<List<UserFavorite>> getFavoriteStops() {
    return _remoteDatasource.getFavorites(type: 'stop');
  }

  // Get all favorite routes for the current authenticated user
  Future<List<UserFavorite>> getFavoriteRoutes() {
    return _remoteDatasource.getFavorites(type: 'route');
  }

  // Add a stop as favorite for the current authenticated user
  Future<UserFavorite> addFavoriteStop({
    required String stopId,
    String? label,
  }) {
    return _remoteDatasource.addFavorite(
      stopId: stopId,
      label: label,
      type: 'stop',
    );
  }

  // Add a route as favorite for the current authenticated user
  Future<UserFavorite?> addFavoriteRoute({
    required String routeId,
    String? label,
  }) async {
    // Check if already exists
    final existing = (await getFavoriteRoutes())
        .where((fav) => fav.routeId == routeId)
        .toList();
    if (existing.isNotEmpty) {
      // Already exists, do not add duplicate
      return null;
    }
    return _remoteDatasource.addFavorite(
      routeId: routeId,
      label: label ?? '',
      type: 'route',
    );
  }

  // Remove a favorite for the current authenticated user
  Future<void> removeFavorite(String favoriteId) {
    return _remoteDatasource.removeFavorite(favoriteId);
  }
}
