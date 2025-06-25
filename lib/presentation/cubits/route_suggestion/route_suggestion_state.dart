import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class RouteSuggestionState extends Equatable {
  final LatLng? startLatLng;
  final String? startName;
  final LatLng? endLatLng;
  final String? endName;
  final double? distanceInKm;
  final List<BusRoute> suggestedBusRoutes;
  final bool isLoading;
  final String? errorMessage;
  final bool isBusActive;
  final int maxRoutes;

  const RouteSuggestionState({
    this.startLatLng,
    this.startName,
    this.endLatLng,
    this.endName,
    this.distanceInKm,
    this.suggestedBusRoutes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isBusActive = false,
    this.maxRoutes = 1,
  });

  RouteSuggestionState copyWith({
    LatLng? userLatLng,
    LatLng? startLatLng,
    String? startName,
    LatLng? endLatLng,
    String? endName,
    double? distanceInKm,
    List<BusRoute>? suggestedBusRoutes,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isBusActive,
    int? maxRoutes,
  }) {
    return RouteSuggestionState(
      startLatLng: startLatLng ?? this.startLatLng,
      startName: startName ?? this.startName,
      endLatLng: endLatLng ?? this.endLatLng,
      endName: endName ?? this.endName,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      suggestedBusRoutes: suggestedBusRoutes ?? this.suggestedBusRoutes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      isBusActive: isBusActive ?? this.isBusActive,
      maxRoutes: maxRoutes ?? this.maxRoutes,
    );
  }

  @override
  List<Object?> get props => [
    startLatLng,
    startName,
    endLatLng,
    endName,
    distanceInKm,
    suggestedBusRoutes,
    isLoading,
    errorMessage,
    isBusActive,
    maxRoutes,
  ];
}
