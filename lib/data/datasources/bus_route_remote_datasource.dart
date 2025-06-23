import 'package:busmapcantho/data/model/route_stop.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/bus_route.dart';
import '../model/bus_stop.dart';

@lazySingleton
class BusRouteRemoteDatasource {
  final SupabaseClient _client;

  BusRouteRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<BusRoute>> getBusRoutes() async {
    try {
      final response = await _client
          .from('routes')
          .select('*, agencies(name)')
          .order('route_number');

      return response.map((data) {
        // Extract agency_name from the nested agencies object
        final agencyName =
            data['agencies'] != null ? data['agencies']['name'] : null;

        // Create a new map with agency_name at the top level
        final routeData = {...data, 'agency_name': agencyName};

        return BusRoute.fromJson(routeData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load bus routes: $e');
    }
  }

  Future<BusRoute> getBusRouteById(String id) async {
    try {
      final routeData =
          await _client
              .from('routes')
              .select('*, agencies(name)')
              .eq('id', id)
              .single();

      // Extract agency_name from the nested agencies object
      final agencyName =
          routeData['agencies'] != null ? routeData['agencies']['name'] : null;

      // Create a new map with agency_name at the top level
      final routeWithAgency = {...routeData, 'agency_name': agencyName};

      final stopsData = await _client
          .from('route_stops')
          .select(
            'id, route_id, stop_id, sequence, direction, created_at, updated_at, stop:stops(*)',
          )
          .eq('route_id', id)
          .order('sequence');

      final List<RouteStop> routeStops =
          stopsData
              .map<RouteStop>((data) {
                final busStopJson = data['stop'];
                if (busStopJson == null) {
                  throw Exception('Missing stop data in route_stops');
                }
                final busStop = BusStop.fromJson(busStopJson);
                return RouteStop.fromJson(data, busStop);
              })
              .whereType<RouteStop>()
              .toList();

      return BusRoute.fromJson(routeWithAgency, stops: routeStops);
    } catch (e) {
      throw Exception('Failed to load bus route: $e');
    }
  }

  Future<List<BusRoute>> searchBusRoutes(String query) async {
    try {
      final response = await _client
          .from('routes')
          .select('*, agencies(name)')
          .or('route_number.ilike.%$query%,route_name.ilike.%$query%')
          .order('route_number');

      return response.map((data) {
        // Extract agency_name from the nested agencies object
        final agencyName =
            data['agencies'] != null ? data['agencies']['name'] : null;

        // Create a new map with agency_name at the top level
        final routeData = {...data, 'agency_name': agencyName};

        return BusRoute.fromJson(routeData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search bus routes: $e');
    }
  }
}
