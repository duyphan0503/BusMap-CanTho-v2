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
  final List<BusStop> allStops;
  final BusStop? selectedStop;

  const MapLoaded({
    required this.currentPosition,
    required this.allStops,
    this.selectedStop,
  });

  MapLoaded copyWith({
    LatLng? currentPosition,
    List<BusStop>? allStops,
    BusStop? selectedStop,
    bool clearSelected = false,
  }) {
    return MapLoaded(
      currentPosition: currentPosition ?? this.currentPosition,
      allStops: allStops ?? this.allStops,
      selectedStop: clearSelected ? null : (selectedStop ?? this.selectedStop),
    );
  }

  @override
  List<Object?> get props => [currentPosition, allStops, selectedStop];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}