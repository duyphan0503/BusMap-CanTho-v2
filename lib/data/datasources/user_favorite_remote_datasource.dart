import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_favorite.dart';

@lazySingleton
class UserFavoriteRemoteDatasource {
  final SupabaseClient _client;

  UserFavoriteRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<UserFavorite>> getFavorites() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return []; // Return empty list if user not logged in
      }

      final response = await _client
          .from('user_favorites')
          .select('*, stop:stops(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      return response.map((data) => UserFavorite.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<UserFavorite> addFavorite({
    required String stopId,
    required String label,
    required String type,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to add favorites');
      }

      final favoriteData = {
        'user_id': user.id,
        'stop_id': stopId,
        'label': label,
        'type': type,
      };

      final response = await _client
          .from('user_favorites')
          .insert(favoriteData)
          .select('*, stop:stops(*)')
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
