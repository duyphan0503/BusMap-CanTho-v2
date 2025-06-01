import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_favorite.dart';

@lazySingleton
class UserFavoriteRemoteDatasource {
  final SupabaseClient _client;

  UserFavoriteRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<UserFavorite>> getFavorites({String? type}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return []; // Return empty list if user not logged in
      }

      var query = _client
          .from('user_favorites')
          .select('*, stop:stops(*)')
          .eq('user_id', user.id);
      if (type != null) {
        query = query.eq('type', type);
      }
      final response = await query.order('created_at', ascending: false);
      return response.map((data) => UserFavorite.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<UserFavorite> addFavorite({
    String? stopId,
    String? routeId,
    String? label,
    required String type,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to add favorites');
      }

      final favoriteData = {
        'id': 'fav_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user.id,
        'label': label,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      };
      if (type == 'stop') {
        if (stopId == null) {
          throw Exception('Stop ID is required for stop favorites');
        }
        favoriteData['stop_id'] = stopId;
      } else if (type == 'route') {
        if (routeId == null) {
          throw Exception('Route ID is required for route favorites');
        }
        favoriteData['route_id'] = routeId;
      }

      final response =
          await _client
              .from('user_favorites')
              .insert(favoriteData)
              .select('*, stop:stops(*), route:routes(*)')
              .single();

      return UserFavorite.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to remove favorites');
      }

      await _client
          .from('user_favorites')
          .delete()
          .eq('id', favoriteId)
          .eq('user_id', user.id); // Safety check
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }
}
