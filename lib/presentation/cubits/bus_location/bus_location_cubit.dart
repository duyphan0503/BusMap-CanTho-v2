import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/services/bus_realtime_service.dart';
import '../../../data/model/bus_location.dart';

part 'bus_location_state.dart';

@injectable
class BusLocationCubit extends Cubit<BusLocationState> {
  final BusRealtimeService _service;
  Stream<BusLocation>? _stream;
  StreamSubscription? _subscription;

  BusLocationCubit(this._service) : super(BusLocationState.initial());

  void subscribe(String routeId) {
    _subscription?.cancel();
    emit(BusLocationState.initial());
    _stream = _service.subscribeToBusLocations(routeId);
    _subscription = _stream!.listen((loc) {
      final updated = Map<String, BusLocation>.from(state.busLocations)
        ..[loc.vehicleId] = loc;
      emit(state.copyWith(busLocations: updated));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _service.dispose();
    return super.close();
  }
}
