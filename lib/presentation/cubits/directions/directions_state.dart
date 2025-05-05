part of 'directions_cubit.dart';

abstract class DirectionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DirectionsInitial extends DirectionsState {}

class DirectionsLoading extends DirectionsState {}

class DirectionsLoaded extends DirectionsState {
  final List<LatLng> polylinePoints;

  DirectionsLoaded({required this.polylinePoints});

  @override
  List<Object?> get props => [polylinePoints];
}

class DirectionsError extends DirectionsState {
  final String message;

  DirectionsError(this.message);

  @override
  List<Object?> get props => [message];
}
