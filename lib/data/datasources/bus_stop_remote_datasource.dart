import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/bus_stop.dart';

@lazySingleton
class BusStopRemoteDatasource {
  final SupabaseClient _client;

  BusStopRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<BusStop>> getBusStops() async {
    try {
      final response = await _client.from('stops').select().order('name');

      return response.map((data) => BusStop.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load bus stops: $e');
    }
  }

  Future<BusStop> getBusStopById(String id) async {
    try {
      final response =
          await _client.from('stops').select().eq('id', id).single();

      return BusStop.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load bus stop: $e');
    }
  }

  Future<List<BusStop>> searchBusStops(String query) async {
    try {
      final response = await _client
          .from('stops')
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return response.map((data) => BusStop.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to search bus stops: $e');
    }
  }

  Future<List<BusStop>> getNearbyBusStops(
      double lat,
      double lng,
      double radiusInMeters,
      ) async {
    try {
      final response = await _client.rpc(
        'get_nearby_stops',
        params: {
          'ref_lat': lat,
          'ref_lng': lng,
          'radius_meters': radiusInMeters,
        },
      );

      if (response is! List) {
        throw FormatException(
          'Expected a list but got ${response.runtimeType}',
        );
      }

      return response.map((data) => BusStop.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get nearby bus stops: $e');
    }
  }
}
