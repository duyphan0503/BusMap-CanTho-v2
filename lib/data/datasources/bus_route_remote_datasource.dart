import 'package:busmapcantho/data/model/route_stop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection.dart';
import '../model/bus_route.dart';
import '../model/bus_stop.dart';

@injectable
class BusRouteRemoteDatasource {
  final SupabaseClient _client;

  BusRouteRemoteDatasource(this._client);

  Future<List<BusRoute>> getBusRoutes() async {
    final logger = getIt<Logger>();
    try {
      final response = await _client
          .from('routes')
          .select('*, agencies(name)')
          .order('route_number', ascending: true);

      return response.map((data) {
        // Extract agency_name from the nested agencies object
        final agencyName =
            data['agencies'] != null ? data['agencies']['name'] : null;

        // Create a new map with agency_name at the top level
        final routeData = {...data, 'agency_name': agencyName};

        return BusRoute.fromJson(routeData);
      }).toList();
    } catch (e, stack) {
      logger.e('Failed to load bus routes', error: e, stackTrace: stack);
      throw Exception(tr('errorLoadingRoutes'));
    }
  }

  Future<BusRoute> getBusRouteById(String id) async {
    final logger = getIt<Logger>();
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
    } catch (e, stack) {
      logger.e('Failed to load bus route', error: e, stackTrace: stack);
      throw Exception(tr('errorLoadingRouteDetail'));
    }
  }

  Future<List<BusRoute>> searchBusRoutes(String query) async {
    final logger = getIt<Logger>();
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
    } catch (e, stack) {
      logger.e('Failed to search bus routes', error: e, stackTrace: stack);
      throw Exception(tr('errorSearchingRoutes'));
    }
  }
}
