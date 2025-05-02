part of 'map_cubit.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoadSuccess extends MapState {
  final List<BusStop> stops;
  final Position? userPosition;

  MapLoadSuccess({
    required this.stops,
    this.userPosition,
  });
}
class MapFailure extends MapState {
  final String message;
  MapFailure(this.message);
}