part of 'stop_cubit.dart';

abstract class StopState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StopInitial extends StopState {}

class StopLoading extends StopState {}

class StopLoaded extends StopState {
  final List<BusStop> stops;
  final bool hasMore;
  final bool isLoadingMore;
  final DateTime? lastUpdated;

  StopLoaded({
    required this.stops,
    required this.hasMore,
    required this.isLoadingMore,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [stops, hasMore, isLoadingMore, lastUpdated];
}

class StopError extends StopState {
  final String message;

  StopError(this.message);

  @override
  List<Object?> get props => [message];
}