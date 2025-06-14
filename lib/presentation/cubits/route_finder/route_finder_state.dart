import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum LocationSelectionType {
  start,
  end,
  none,
}

class RouteFinderState extends Equatable {
  final String? startName;
  final LatLng? startLatLng;
  final String? endName;
  final LatLng? endLatLng;
  final List<LatLng> routeLine;
  final LocationSelectionType selectionType;
  final bool startInputError; // Added for swap error indication
  final bool endInputError;   // Added for swap error indication

  const RouteFinderState({
    this.startName,
    this.startLatLng,
    this.endName,
    this.endLatLng,
    this.routeLine = const [],
    this.selectionType = LocationSelectionType.none,
    this.startInputError = false, // Default to false
    this.endInputError = false,   // Default to false
  });

  factory RouteFinderState.initial() => const RouteFinderState();

  RouteFinderState copyWith({
    String? startName,
    LatLng? startLatLng,
    String? endName,
    LatLng? endLatLng,
    List<LatLng>? routeLine,
    LocationSelectionType? selectionType,
    bool? startInputError,
    bool? endInputError,
  }) {
    return RouteFinderState(
      startName: startName ?? this.startName,
      startLatLng: startLatLng ?? this.startLatLng,
      endName: endName ?? this.endName,
      endLatLng: endLatLng ?? this.endLatLng,
      routeLine: routeLine ?? this.routeLine,
      selectionType: selectionType ?? this.selectionType,
      startInputError: startInputError ?? this.startInputError,
      endInputError: endInputError ?? this.endInputError,
    );
  }

  @override
  List<Object?> get props => [
        startName,
        startLatLng,
        endName,
        endLatLng,
        routeLine,
        selectionType,
        startInputError,
        endInputError,
      ];
}
