import 'package:injectable/injectable.dart';

import '../datasources/user_favorite_remote_datasource.dart';
import '../model/user_favorite.dart';

@lazySingleton
class UserFavoriteRepository {
  final UserFavoriteRemoteDatasource _remoteDatasource;

  UserFavoriteRepository(this._remoteDatasource);

  // Get all favorites for the current authenticated user
  Future<List<UserFavorite>> getFavorites() {
    return _remoteDatasource.getFavorites();
  }

  // Add a stop as favorite for the current authenticated user
  Future<UserFavorite> addFavorite({
    required String stopId,
    required String label,
    required String type,
  }) {
    return _remoteDatasource.addFavorite(
      stopId: stopId,
      label: label,
      type: type,
    );
  }

  // Remove a favorite for the current authenticated user
  Future<void> removeFavorite(String favoriteId) {
    return _remoteDatasource.removeFavorite(favoriteId);
  }
}
