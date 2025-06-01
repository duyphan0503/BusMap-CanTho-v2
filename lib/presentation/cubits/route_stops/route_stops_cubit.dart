import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/bus_realtime_service.dart';
import '../../../data/model/bus_location.dart';
import '../../../data/model/bus_route.dart';
import '../../../data/model/bus_stop.dart';
import '../../../domain/usecases/bus_routes/get_bus_route_by_id_usecase.dart';
import '../../../domain/usecases/route_stops/get_routes_for_stop_usecase.dart';
part 'route_stops_state.dart';

@injectable
class RouteStopsCubit extends Cubit<RouteStopsState> {
  final GetRoutesForStopUseCase _getRoutesForStopUseCase;
  final GetBusRouteByIdUseCase _getBusRouteByIdUseCase;
  final BusRealtimeService _realtimeService;
  final List<StreamSubscription> _subscriptions = [];

  RouteStopsCubit(
    this._getRoutesForStopUseCase,
    this._getBusRouteByIdUseCase,
    this._realtimeService,
  ) : super(const RouteStopsInitial());

  Future<void> loadRoutesForStop(BusStop stop) async {
    emit(const RouteStopsLoading());
    try {
      final routeIds = await _getRoutesForStopUseCase(stop.id);
      if (routeIds.isEmpty) {
        emit(RouteStopsLoaded(stop: stop, routes: const [], vehicles: const []));
        return;
      }
      final routes = <BusRoute>[];
      for (final routeId in routeIds) {
        try {
          final route = await _getBusRouteByIdUseCase(routeId);
          if (route != null) {
            routes.add(route);
          }
        } catch (e) {
          debugPrint('Error loading route $routeId: $e');
        }
      }
      routes.sort((a, b) => a.routeNumber.compareTo(b.routeNumber));
      emit(RouteStopsLoaded(stop: stop, routes: routes, vehicles: const []));
      _subscribeToRouteLocations(routeIds);
    } catch (e) {
      emit(RouteStopsError('Không thể tải tuyến: ${e.toString()}'));
    }
  }

  void _subscribeToRouteLocations(List<String> routeIds) {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    for (final routeId in routeIds) {
      final stream = _realtimeService.subscribeToBusLocations(routeId);
      final subscription = stream.listen(_handleBusLocationUpdate);
      _subscriptions.add(subscription);
    }
  }

  void _handleBusLocationUpdate(BusLocation location) {
    if (state is RouteStopsLoaded) {
      final currentState = state as RouteStopsLoaded;
      final updatedVehicles = List<BusLocation>.from(currentState.vehicles);
      final existingIndex = updatedVehicles.indexWhere(
        (v) => v.vehicleId == location.vehicleId,
      );
      if (existingIndex >= 0) {
        updatedVehicles[existingIndex] = location;
      } else {
        updatedVehicles.add(location);
      }
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      updatedVehicles.removeWhere((v) => v.timestamp.isBefore(fiveMinutesAgo));
      updatedVehicles.sort((a, b) => a.routeId.compareTo(b.routeId));
      emit(currentState.copyWith(vehicles: updatedVehicles));
    }
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    return super.close();
  }
}