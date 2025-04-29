import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/route_stop.dart';

class RouteStopRemoteDatasource {
  final SupabaseClient _client;

  RouteStopRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<RouteStop>> getStopsByRouteId(String routeId) async {
    final response = await _client
        .from('route_stops')
        .select()
        .eq('route_id', routeId);
    return (response as List).map((e) => RouteStop.fromJson(e)).toList();
  }

  Future<void> addRouteStop(RouteStop routeStop) async {
    await _client.from('route_stops').insert(routeStop.toJson());
  }

  Future<void> deleteRouteStop(String routeId, String stopId) async {
    await _client
        .from('route_stops')
        .delete()
        .eq('route_id', routeId)
        .eq('stop_id', stopId);
  }
}