import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/bus_stop.dart';
import '../model/route_stop.dart';

@lazySingleton
class RouteStopRemoteDatasource {
  final SupabaseClient _client;

  RouteStopRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<RouteStop>> getRouteStops(String routeId, int direction) async {
    try {
      final response = await _client
          .from('route_stops')
          .select('id, route_id, stop_id, sequence, direction, created_at, updated_at, stop:stops(*)')
          .eq('route_id', routeId)
          .eq('direction', direction)
          .order('sequence');
      
      return response.map((data) {
        final stop = BusStop.fromJson(data['stop']);
        return RouteStop.fromJson(data, stop);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load route stops: $e');
    }
  }

  Future<List<String>> getRoutesForStop(String stopId) async {
    try {
      final response = await _client
          .from('route_stops')
          .select('route_id, direction')
          .eq('stop_id', stopId);
      
      // Extract unique route IDs
      return response
          .map((data) => data['route_id'] as String)
          .toSet()
          .toList();
    } catch (e) {
      throw Exception('Failed to load routes for stop: $e');
    }
  }

  // New method to get specific route-stop combination
  Future<RouteStop?> getRouteStop(String routeId, String stopId, int direction) async {
    try {
      final response = await _client
          .from('route_stops')
          .select('id, route_id, stop_id, sequence, direction, created_at, updated_at, stop:stops(*)')
          .eq('route_id', routeId)
          .eq('stop_id', stopId)
          .eq('direction', direction)
          .single();

      if (response == null) return null;

      final stop = BusStop.fromJson(response['stop']);
      return RouteStop.fromJson(response, stop);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        // No rows returned
        return null;
      }
      throw Exception('Failed to load route stop: $e');
    }
  }
}
