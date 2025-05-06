import 'dart:async';

import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/data/repositories/bus_stop_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
    _cancelPositionStream();
    return super.close();
  }

  void _cancelPositionStream() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> initialize() async {
    emit(MapLoading());
    
    try {
      // Check location permissions first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!_isClosed) emit(MapError('Location services are disabled.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!_isClosed) emit(MapError('Location permissions are denied.'));
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (!_isClosed) {
          emit(MapError(
            'Location permissions are permanently denied, we cannot request permissions.',
          ));
        }
        return;
      }

      // Cancel any existing stream before creating a new one
      _cancelPositionStream();

      // Get current position once
      final position = await Geolocator.getCurrentPosition();
      final nearbyStops = await _loadNearbyStops(
        position.latitude,
        position.longitude,
      );
      
      if (!_isClosed) {
        _emitSuccess(
          position.latitude,
          position.longitude,
          nearbyStops,
        );
      }

      // Start listening to position updates
      _positionStream = Geolocator.getPositionStream().listen(
        (Position position) async {
          if (_isClosed) return;
          
          try {
            final nearbyStops = await _loadNearbyStops(
              position.latitude,
              position.longitude,
            );
            
            if (!_isClosed) {
              _emitSuccess(
                position.latitude,
                position.longitude,
                nearbyStops,
              );
            }
          } catch (e) {
            if (!_isClosed) {
              emit(MapError('Error fetching nearby stops: $e'));
            }
          }
        },
        onError: (error) {
          if (!_isClosed) {
            emit(MapError('Location stream error: $error'));
          }
        },
      );
    } catch (e) {
      if (!_isClosed) {
        emit(MapError('Error initializing map: $e'));
      }
    }
  }

  void _emitSuccess(
    double latitude,
    double longitude,
    List<BusStop> nearbyStops,
  ) {
    if (!_isClosed) {
      emit(MapLoaded(
        currentPosition: LatLng(latitude, longitude),
        nearbyStops: nearbyStops,
      ));
    }
  }

  Future<List<BusStop>> _loadNearbyStops(double lat, double lng) async {
    try {
      return await _busStopRepository.getNearbyBusStops(lat, lng, 1000);
    } catch (e) {
      debugPrint('Error loading nearby stops: $e');
      return [];
    }
  }

  void selectBusStop(BusStop stop) {
    if (_isClosed) return;
    
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedStop: stop));
    }
  }

  void clearSelectedBusStop() {
    if (_isClosed) return;
    
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedStop: null));
    }
  }
}
