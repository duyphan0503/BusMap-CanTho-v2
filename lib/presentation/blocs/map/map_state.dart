
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as osm;

import '../../../data/model/bus_stop.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final osm.LatLng currentPosition;
  final osm.LatLngBounds? visibleBounds;
  final BusStop? selectedStop;

  const MapLoaded({
    required this.currentPosition,
    this.visibleBounds,
    this.selectedStop,
  });

  MapLoaded copyWith({
    osm.LatLng? currentPosition,
    osm.LatLngBounds? visibleBounds,
    BusStop? selectedStop,
    bool clearSelected = false,
  }) {
    return MapLoaded(
      currentPosition: currentPosition ?? this.currentPosition,
      visibleBounds: visibleBounds ?? this.visibleBounds,
      selectedStop: clearSelected ? null : (selectedStop ?? this.selectedStop),
    );
  }

  @override
  List<Object?> get props => [currentPosition, visibleBounds, selectedStop];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
