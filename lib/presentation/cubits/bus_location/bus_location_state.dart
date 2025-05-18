part of 'bus_location_cubit.dart';

class BusLocationState extends Equatable {
  final Map<String, BusLocation> busLocations;

  const BusLocationState({required this.busLocations});

  factory BusLocationState.initial() => const BusLocationState(busLocations: {});

  BusLocationState copyWith({Map<String, BusLocation>? busLocations}) =>
      BusLocationState(busLocations: busLocations ?? this.busLocations);

  @override
  List<Object?> get props => [busLocations];
}