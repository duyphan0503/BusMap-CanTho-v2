import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/bus_route.dart';

class BusRouteRemoteDatasource {
  final SupabaseClient _client;

  BusRouteRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<BusRoute>> getAllBusRoutes() async {
    final response = await _client.from('bus_routes').select();
    return (response as List).map((e) => BusRoute.fromJson(e)).toList();
  }

  Future<BusRoute?> getBusRouteById(String id) async {
    final response =
        await _client.from('bus_routes').select().eq('id', id).maybeSingle();
    return response != null ? BusRoute.fromJson(response) : null;
  }

  Future<void> addBusRoute(BusRoute route) async {
    await _client.from('bus_routes').insert(route.toJson());
  }

  Future<void> updateBusRoute(BusRoute route) async {
    await _client.from('bus_routes').update(route.toJson()).eq('id', route.id);
  }

  Future<void> deleteBusRoute(String id) async {
    await _client.from('bus_routes').delete().eq('id', id);
  }
}
