import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/favorite_route_remote_datasource.dart';
import '../model/bus_route.dart';

@lazySingleton
class FavoriteRouteRepository {
  final FavoriteRouteRemoteDatasource _remoteDatasource;
  final SupabaseClient _client;

  FavoriteRouteRepository(this._remoteDatasource, [SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  // Save a route as favorite for the current authenticated user
  Future<void> saveFavoriteRoute(String routeId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to save favorites');
    }
    return _remoteDatasource.saveFavoriteRoute(user.id, routeId);
  }

  // Get favorite routes for the current authenticated user
  Future<List<BusRoute>> getFavoriteRoutes() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return [];
    }
    return _remoteDatasource.getFavoriteRoutes(user.id);
  }

  // Remove a route from favorites for the current authenticated user
  Future<void> removeFavoriteRoute(String routeId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to remove favorites');
    }
    return _remoteDatasource.removeFavoriteRoute(user.id, routeId);
  }

  // Deprecated methods that required explicit user ID
  @deprecated
  Future<void> saveFavoriteRouteForUser(String userId, String routeId) {
    return _remoteDatasource.saveFavoriteRoute(userId, routeId);
  }

  @deprecated
  Future<List<BusRoute>> getFavoriteRoutesForUser(String userId) {
    return _remoteDatasource.getFavoriteRoutes(userId);
  }

  @deprecated
  Future<void> removeFavoriteRouteForUser(String userId, String routeId) {
    return _remoteDatasource.removeFavoriteRoute(userId, routeId);
  }
}
