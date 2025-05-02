import 'dart:async';

import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/domain/usecases/bus_stop/get_all_bus_stops_usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

part 'map_state.dart';

@injectable
class MapCubit extends Cubit<MapState> {
  final GetAllBusStopsUseCase _getAllBusStops;
  StreamSubscription<Position>? _positionSub;
  List<BusStop> _stops = [];
  Position? _currentPosition;

  MapCubit(this._getAllBusStops) : super(MapInitial());

  /// Call this in initState
  Future<void> initialize() async {
    emit(MapLoading());
    // 1. Try loading bus stops
    try {
      _stops = await _getAllBusStops();
    } catch (e) {
      // Emit a non‐blocking failure
      emit(MapFailure(e.toString()));
      debugPrint('Error loading bus stops: $e');
    }
    // 2. Setup location tracking (swallow errors)
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('locationPermissionDenied');
      }
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        _currentPosition = pos;
        _emitSuccess();
      });
      // initial fetch
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (_) {
      // ignore location errors
    }
    // 3. Finally emit success with current data (may be no stops or no location)
    _emitSuccess();
  }

  void _emitSuccess() {
    emit(MapLoadSuccess(stops: _stops, userPosition: _currentPosition));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}