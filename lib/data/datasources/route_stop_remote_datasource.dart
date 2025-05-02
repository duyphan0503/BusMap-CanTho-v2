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
          .select('*, stop:stops(*)')
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
          .select('route_id')
          .eq('stop_id', stopId)
          .order('route_id');
      
      // Extract unique route IDs
      return response
          .map((data) => data['route_id'] as String)
          .toSet()
          .toList();
    } catch (e) {
      throw Exception('Failed to load routes for stop: $e');
    }
  }
}
