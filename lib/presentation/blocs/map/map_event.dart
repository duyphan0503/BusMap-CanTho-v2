import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:geolocator/geolocator.dart';

import '../../../data/model/bus_stop.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMap extends MapEvent {}

class UpdateVisibleBounds extends MapEvent {
  final osm.LatLngBounds? bounds;

  const UpdateVisibleBounds(this.bounds);

  @override
  List<Object?> get props => [bounds];
}

class SelectBusStop extends MapEvent {
  final BusStop stop;

  const SelectBusStop(this.stop);

  @override
  List<Object> get props => [stop];
}

class ClearSelectedBusStop extends MapEvent {}

// New event for position updates
class UpdateUserLocation extends MapEvent {
  final Position position;

  const UpdateUserLocation(this.position);

  @override
  List<Object> get props => [position];
}

// New event for position stream errors
class LocationStreamError extends MapEvent {
  final String error;

  const LocationStreamError(this.error);

  @override
  List<Object> get props => [error];
}
