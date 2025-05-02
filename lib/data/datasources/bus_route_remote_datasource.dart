import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/bus_route.dart';

@lazySingleton
class BusRouteRemoteDatasource {
  final SupabaseClient _client;

  BusRouteRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<BusRoute>> getBusRoutes() async {
    try {
      final response = await _client
          .from('routes')
          .select('*, agency:agencies(*)')
          .order('route_number');

      return response.map((data) => BusRoute.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load bus routes: $e');
    }
  }

  Future<BusRoute> getBusRouteById(String id) async {
    try {
      final response =
          await _client
              .from('routes')
              .select('*, agency:agencies(*)')
              .eq('id', id)
              .single();

      return BusRoute.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load bus route: $e');
    }
  }

  Future<List<BusRoute>> searchBusRoutes(String query) async {
    try {
      final response = await _client
          .from('routes')
          .select('*, agency:agencies(*)')
          .or('route_number.ilike.%$query%,route_name.ilike.%$query%')
          .order('route_number');

      return response.map((data) => BusRoute.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to search bus routes: $e');
    }
  }
}
