part of 'stop_cubit.dart';

abstract class StopState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StopInitial extends StopState {}

class StopLoading extends StopState {}

class StopLoaded extends StopState {
  final List<BusStop> stops;

  StopLoaded(this.stops);

  @override
  List<Object?> get props => [stops];
}

class StopError extends StopState {
  final String message;

  StopError(this.message);

  @override
  List<Object?> get props => [message];
}
