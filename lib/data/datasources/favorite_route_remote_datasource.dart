import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class FavoriteRouteRemoteDatasource {
  final SupabaseClient _client;

  FavoriteRouteRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<void> saveFavoriteRoute(String routeId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User must be logged in');

    final existing =
        await _client
            .from('user_favorites')
            .select('id')
            .eq('user_id', user.id)
            .eq('route_id', routeId)
            .eq('type', 'route')
            .maybeSingle();

    if (existing == null) {
      await _client.from('user_favorites').insert({
        'user_id': user.id,
        'route_id': routeId,
        'type': 'route',
      });
    }
  }

  Future<List<BusRoute>> getFavoriteRoutes() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return [];
    }

    // Fetch saved route IDs
    final favs = await _client
        .from('user_favorites')
        .select('route_id')
        .eq('user_id', user.id)
        .eq('type', 'route');

    final routeIds =
        (favs as List)
            .where((e) => e['route_id'] != null)
            .map((e) => e['route_id'] as String)
            .toList();

    if (routeIds.isEmpty) {
      return [];
    }

    // Load full route data
    final routesResponse = await _client
        .from('routes')
        .select('*, agency:agencies(*)')
        .inFilter('id', routeIds);

    return (routesResponse as List).map((e) => BusRoute.fromJson(e)).toList();
  }

  Future<void> removeFavoriteRoute(String routeId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to remove favorites');
    }
    await _client
        .from('user_favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('route_id', routeId)
        .eq('type', 'route');
  }
}
