import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection.dart';
import '../model/bus_stop.dart';

@lazySingleton
class BusStopRemoteDatasource {
  final SupabaseClient _client;

  BusStopRemoteDatasource(this._client);

  final _logger = getIt<Logger>();

  Future<List<BusStop>> getBusStops() async {
    try {
      final response = await _client.from('stops').select().order('name');
      return response.map((data) => BusStop.fromJson(data)).toList();
    } catch (e, stack) {
      _logger.e('Failed to load bus stops', error: e, stackTrace: stack);
      throw Exception(tr('errorLoadingBusStops'));
    }
  }

  Future<BusStop> getBusStopById(String id) async {
    try {
      final response =
          await _client.from('stops').select().eq('id', id).single();
      return BusStop.fromJson(response);
    } catch (e, stack) {
      _logger.e('Failed to load bus stop', error: e, stackTrace: stack);
      throw Exception(tr('errorLoadingBusStops'));
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
    } catch (e, stack) {
      _logger.e('Failed to search bus stops', error: e, stackTrace: stack);
      throw Exception(tr('errorSearching'));
    }
  }

  Future<List<BusStop>> getNearbyBusStops(
    double lat,
    double lng,
    double radiusInMeters, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _client.rpc(
        'get_nearby_stops',
        params: {
          'ref_lat': lat,
          'ref_lng': lng,
          'radius_meters': radiusInMeters,
          'limit_rows': limit,
          'offset_rows': offset,
        },
      );

      if (response is! List) {
        throw FormatException(
          'Expected a list but got ${response.runtimeType}',
        );
      }

      return response.map((data) => BusStop.fromJson(data)).toList();
    } catch (e, stack) {
      _logger.e('Failed to get nearby bus stops', error: e, stackTrace: stack);
      throw Exception(tr('fetchError'));
    }
  }
}
