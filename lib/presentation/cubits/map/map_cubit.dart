import 'dart:async';

import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/data/repositories/bus_stop_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

part 'map_state.dart';

@injectable
class MapCubit extends Cubit<MapState> {
  final BusStopRepository _busStopRepository;
  StreamSubscription<Position>? _positionStream;
  bool _isClosed = false;

  MapCubit(this._busStopRepository) : super(MapInitial());

  @override
  Future<void> close() {
    _isClosed = true;
    _positionStream?.cancel();
    return super.close();
  }

  Future<bool> _checkLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!_isClosed) emit(MapError('Location services are disabled.'));
      return false;
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) {
        if (!_isClosed) emit(MapError('Location permissions are denied.'));
        return false;
      }
    }
    if (p == LocationPermission.deniedForever) {
      if (!_isClosed) {
        emit(MapError('Location permissions permanently denied.'));
      }
      return false;
    }
    return true;
  }

  Future<void> initialize() async {
    emit(MapLoading());

    try {
      if (!await _checkLocationPermission()) return;

      // 1. Load tất cả stop
      final stops = await _busStopRepository.getAllBusStops();

      // 2. Lấy vị trí hiện tại
      final pos = await Geolocator.getCurrentPosition();

      if (!_isClosed) {
        emit(
          MapLoaded(
            currentPosition: LatLng(pos.latitude, pos.longitude),
            allStops: stops,
          ),
        );
      }

      // 3. Listen vị trí
      _positionStream = Geolocator.getPositionStream().listen(
        (newPos) {
          if (_isClosed) return;
          final s = state;
          if (s is MapLoaded) {
            emit(
              s.copyWith(
                currentPosition: LatLng(newPos.latitude, newPos.longitude),
              ),
            );
          }
        },
        onError: (e) {
          if (!_isClosed) emit(MapError('Location stream error: $e'));
        },
      );
    } catch (e) {
      if (!_isClosed) emit(MapError('Error initializing map: $e'));
    }
  }

  void selectBusStop(BusStop stop) {
    if (_isClosed) return;
    final s = state;
    if (s is MapLoaded) {
      emit(s.copyWith(selectedStop: stop));
    }
  }

  void clearSelectedBusStop() {
    if (_isClosed) return;
    final s = state;
    if (s is MapLoaded) {
      emit(s.copyWith(clearSelected: true));
    }
  }
}
