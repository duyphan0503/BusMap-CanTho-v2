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

  const RouteFinderState({
    this.startName,
    this.startLatLng,
    this.endName,
    this.endLatLng,
    this.routeLine = const [],
    this.selectionType = LocationSelectionType.none,
  });

  factory RouteFinderState.initial() => const RouteFinderState();

  RouteFinderState copyWith({
    String? startName,
    LatLng? startLatLng,
    String? endName,
    LatLng? endLatLng,
    List<LatLng>? routeLine,
    LocationSelectionType? selectionType,
  }) {
    return RouteFinderState(
      startName: startName ?? this.startName,
      startLatLng: startLatLng ?? this.startLatLng,
      endName: endName ?? this.endName,
      endLatLng: endLatLng ?? this.endLatLng,
      routeLine: routeLine ?? this.routeLine,
      selectionType: selectionType ?? this.selectionType,
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
  ];
}
