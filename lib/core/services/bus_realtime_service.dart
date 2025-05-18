import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/bus_location.dart';

@lazySingleton
class BusRealtimeService {
  final SupabaseClient client;
  RealtimeChannel? _channel;
  final StreamController<BusLocation> _locationController = StreamController.broadcast();
  bool _isDisposed = false;

  BusRealtimeService(this.client);

  Stream<BusLocation> subscribeToBusLocations(String routeId) {
    _channel?.unsubscribe();
    _channel = client.channel('public:bus_locations')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'bus_locations',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'route_id',
        value: routeId,
      ),
      callback: (payload) {
        if (!_isDisposed) {
          final location = BusLocation.fromJson(payload.newRecord);
          _locationController.add(location);
        }
      },
    )
        .subscribe();
    return _locationController.stream;
  }

  void dispose() {
    _isDisposed = true;
    _channel?.unsubscribe();
    _locationController.close();
  }
}