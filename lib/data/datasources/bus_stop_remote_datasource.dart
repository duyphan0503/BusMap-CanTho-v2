import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/bus_stop.dart';

class BusStopRemoteDatasource {
  final SupabaseClient _client;

  BusStopRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<BusStop>> getAllBusStops() async {
    final response = await _client.from('bus_stops').select();
    return (response as List).map((e) => BusStop.fromJson(e)).toList();
  }

  Future<BusStop?> getBusStopById(String id) async {
    final response =
        await _client.from('bus_stops').select().eq('id', id).maybeSingle();
    return response != null ? BusStop.fromJson(response) : null;
  }

  Future<List<BusStop>> getBusStopsByRouteId(String routeId) async {
    final response = await _client
        .from('bus_stops')
        .select()
        .eq('route_id', routeId);
    return (response as List).map((e) => BusStop.fromJson(e)).toList();
  }

  Future<void> addBusStop(BusStop stop) async {
    await _client.from('bus_stops').insert(stop.toJson());
  }

  Future<void> updateBusStop(BusStop stop) async {
    await _client.from('bus_stops').update(stop.toJson()).eq('id', stop.id);
  }

  Future<void> deleteBusStop(String id) async {
    await _client.from('bus_stops').delete().eq('id', id);
  }
}
