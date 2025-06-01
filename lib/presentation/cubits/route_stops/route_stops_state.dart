part of 'route_stops_cubit.dart';

@immutable
abstract class RouteStopsState {
  const RouteStopsState();
}

class RouteStopsInitial extends RouteStopsState {
  const RouteStopsInitial();
}

class RouteStopsLoading extends RouteStopsState {
  const RouteStopsLoading();
}

class RouteStopsLoaded extends RouteStopsState {
  final BusStop stop;
  final List<BusRoute> routes;
  final List<BusLocation> vehicles;
  final bool isMonitoring;

  const RouteStopsLoaded({
    required this.stop,
    required this.routes,
    required this.vehicles,
    this.isMonitoring = false,
  });

  RouteStopsLoaded copyWith({
    BusStop? stop,
    List<BusRoute>? routes,
    List<BusLocation>? vehicles,
    bool? isMonitoring,
  }) {
    return RouteStopsLoaded(
      stop: stop ?? this.stop,
      routes: routes ?? this.routes,
      vehicles: vehicles ?? this.vehicles,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteStopsLoaded &&
        other.stop.id == stop.id &&
        listEquals(other.routes, routes) &&
        other.isMonitoring == isMonitoring &&
        _areVehicleListsEqual(other.vehicles, vehicles);
  }

  bool _areVehicleListsEqual(List<BusLocation> list1, List<BusLocation> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i].vehicleId != list2[i].vehicleId ||
          list1[i].routeId != list2[i].routeId ||
          list1[i].timestamp != list2[i].timestamp) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        stop.id,
        Object.hashAll(routes.map((r) => r.id)),
        isMonitoring,
        Object.hashAll(vehicles.map((v) => v.vehicleId)),
      );
}

class RouteStopsError extends RouteStopsState {
  final String message;
  const RouteStopsError(this.message);
}
