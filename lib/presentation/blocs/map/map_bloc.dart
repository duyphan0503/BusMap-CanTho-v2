import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart' as osm;

import 'map_event.dart';
import 'map_state.dart';

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  StreamSubscription<Position>? _positionStream;

  MapBloc() : super(MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<UpdateVisibleBounds>(_onUpdateVisibleBounds);
    on<SelectBusStop>(_onSelectBusStop);
    on<ClearSelectedBusStop>(_onClearSelectedBusStop);

    // Add handlers for the new events
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<LocationStreamError>(_onLocationStreamError);
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    try {
      if (!await _checkLocationPermission(emit)) return;

      final pos = await Geolocator.getCurrentPosition();

      emit(
        MapLoaded(
          currentPosition: osm.LatLng(pos.latitude, pos.longitude),
          visibleBounds: null,
        ),
      );

      // Set up the position stream but add events to the bloc instead of emitting directly
      _positionStream?.cancel();
      _positionStream = Geolocator.getPositionStream().listen(
        (newPos) {
          // Add an event instead of emitting directly
          add(UpdateUserLocation(newPos));
        },
        onError: (e) {
          // Add an event for errors too
          add(LocationStreamError(e.toString()));
        },
      );
    } catch (e) {
      emit(MapError('Error initializing map: $e'));
    }
  }

  // New handler for position updates
  void _onUpdateUserLocation(UpdateUserLocation event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(
        currentState.copyWith(
          currentPosition: osm.LatLng(
            event.position.latitude,
            event.position.longitude,
          ),
        ),
      );
    }
  }

  // New handler for location stream errors
  void _onLocationStreamError(
    LocationStreamError event,
    Emitter<MapState> emit,
  ) {
    emit(MapError('Location stream error: ${event.error}'));
  }

  Future<void> _onUpdateVisibleBounds(
    UpdateVisibleBounds event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is MapLoaded &&
        (currentState.visibleBounds == null ||
            currentState.visibleBounds != event.bounds)) {
      emit(currentState.copyWith(visibleBounds: event.bounds));
    }
  }

  Future<void> _onSelectBusStop(
    SelectBusStop event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedStop: event.stop));
    }
  }

  Future<void> _onClearSelectedBusStop(
    ClearSelectedBusStop event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(clearSelected: true));
    }
  }

  Future<bool> _checkLocationPermission(Emitter<MapState> emit) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      emit(MapError('Location services are disabled.'));
      return false;
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) {
        emit(MapError('Location permissions are denied.'));
        return false;
      }
    }
    if (p == LocationPermission.deniedForever) {
      emit(MapError('Location permissions permanently denied.'));
      return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }
}
