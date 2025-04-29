import '../../../../data/model/bus_route.dart';

abstract class BusRouteState {}

class BusRouteInitial extends BusRouteState {}

class BusRouteLoading extends BusRouteState {}

class BusRouteLoaded extends BusRouteState {
  final List<BusRoute> busRoutes;

  BusRouteLoaded(this.busRoutes);
}

class BusRouteError extends BusRouteState {
  final String message;

  BusRouteError(this.message);
}

