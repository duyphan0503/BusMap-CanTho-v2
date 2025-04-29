import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteRouteRemoteDatasource {
  final SupabaseClient _client;

  FavoriteRouteRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<void> saveFavoriteRoute(String userId, String routeId) async {
    final response =
        await _client
            .from('favorite_routes')
            .select()
            .eq('user_id', userId)
            .eq('route_id', routeId)
            .eq('type', 'route')
            .maybeSingle();

    if (response == null) {
      await _client.from('user_favorites').insert({
        'user_id': userId,
        'route_id': routeId,
        'type': 'route',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<String>> getFavoriteRoutes(String userId) async {
    final response = await _client
        .from('user_favorites')
        .select('route_id')
        .eq('user_id', userId)
        .eq('type', 'route');

    return (response as List)
        .where((item) => item['route_id'] != null)
        .map((item) => item['route_id'] as String)
        .toList();
  }

  Future<void> removeFavoriteRoute(String userId, String routeId) async {
    await _client
        .from('user_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('route_id', routeId)
        .eq('type', 'route');
  }
}
