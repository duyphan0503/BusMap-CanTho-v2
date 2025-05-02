import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/bus_location.dart';

@lazySingleton
class BusLocationRemoteDatasource {
  final SupabaseClient _client;

  BusLocationRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<BusLocation>> getBusLocationsByRouteId(String routeId) async {
    try {
      final response = await _client
          .from('bus_locations')
          .select()
          .eq('route_id', routeId);
      
      return response.map((data) => BusLocation.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load bus locations: $e');
    }
  }

  Stream<List<BusLocation>> subscribeToBusLocations(String routeId) {
    return _client
        .from('bus_locations')
        .stream(primaryKey: ['vehicle_id'])
        .eq('route_id', routeId)
        .map((data) => data.map((item) => BusLocation.fromJson(item)).toList());
  }

  Future<void> updateBusLocation(BusLocation busLocation) async {
    try {
      await _client
          .from('bus_locations')
          .upsert(busLocation.toJson());
    } catch (e) {
      throw Exception('Failed to update bus location: $e');
    }
  }
}
