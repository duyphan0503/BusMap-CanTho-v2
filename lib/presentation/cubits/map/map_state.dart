part of 'map_cubit.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final LatLng currentPosition;
  final List<BusStop> nearbyStops;
  final BusStop? selectedStop;

  const MapLoaded({
    required this.currentPosition,
    required this.nearbyStops,
    this.selectedStop,
  });

  MapLoaded copyWith({
    LatLng? currentPosition,
    List<BusStop>? nearbyStops,
    BusStop? selectedStop,
    bool clearSelectedStop = false,
  }) {
    return MapLoaded(
      currentPosition: currentPosition ?? this.currentPosition,
      nearbyStops: nearbyStops ?? this.nearbyStops,
      selectedStop: clearSelectedStop ? null : (selectedStop ?? this.selectedStop),
    );
  }

  @override
  List<Object?> get props => [currentPosition, nearbyStops, selectedStop];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object> get props => [message];
}
