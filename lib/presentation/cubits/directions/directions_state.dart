part of 'directions_cubit.dart';

abstract class DirectionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DirectionsInitial extends DirectionsState {}

class DirectionsLoading extends DirectionsState {}

class DirectionsLoaded extends DirectionsState {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final String durationText;
  final List<Map<String, dynamic>>? steps;
  final Map<String, dynamic> transportInfo;
  final String transportMode;
  final bool hasElevation;
  final double? ascend;
  final double? descend;

  DirectionsLoaded({
    required this.polylinePoints,
    required this.distanceText,
    required this.durationText,
    this.steps,
    this.transportInfo = const {},
    this.transportMode = 'car',
    this.hasElevation = false,
    this.ascend,
    this.descend,
  });

  String get formattedDistance {
    final distance = double.parse(distanceText);
    return distance >= 1000
        ? '${(distance / 1000).toStringAsFixed(1)} km'
        : '${distance.toStringAsFixed(0)} m';
  }

  String get formattedDuration {
    final duration = double.parse(durationText);
    final hours = (duration / 3600).floor();
    final minutes = ((duration % 3600) / 60).ceil();

    if (hours > 0) {
      return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
    } else {
      return '$minutes phút';
    }
  }

  @override
  List<Object?> get props => [
    polylinePoints,
    distanceText,
    durationText,
    steps,
    transportInfo,
    transportMode,
    hasElevation,
    ascend,
    descend
  ];
}

class DirectionsError extends DirectionsState {
  final String message;

  DirectionsError(this.message);

  @override
  List<Object?> get props => [message];
}
