import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../../core/services/bus_realtime_service.dart';
import '../../../data/model/bus_location.dart';
import '../../../data/model/bus_route.dart';
import '../../../data/model/bus_stop.dart';
import '../../../data/model/route_stop.dart';
import '../../../domain/usecases/bus_routes/get_bus_route_by_id_usecase.dart';
import '../../../domain/usecases/route_geometry/get_route_geometry_usecase.dart';
import '../../../domain/usecases/route_stops/get_route_stops_for_route_usecase.dart';
import '../../../domain/usecases/route_stops/get_routes_for_stop_usecase.dart';

part 'route_stops_state.dart';

@injectable
class RouteStopsCubit extends Cubit<RouteStopsState> {
  final GetRoutesForStopUseCase _getRoutesForStopUseCase;
  final GetBusRouteByIdUseCase _getBusRouteByIdUseCase;
  final BusRealtimeService _realtimeService;
  final GetRouteGeometryUseCase _getRouteGeometryUseCase;
  final GetRouteStopsForRouteUseCase _getRouteStopsForRouteUseCase;
  final List<StreamSubscription> _subscriptions = [];

  // Holds geometry for current route: direction -> list of LatLng
  Map<int, List<osm.LatLng>> _routeGeometry = {};

  // Add this usecase for getting all stops of a route
  @factoryMethod
  RouteStopsCubit.withGetRouteStopsUseCase(
    this._getRoutesForStopUseCase,
    this._getBusRouteByIdUseCase,
    this._realtimeService,
    this._getRouteGeometryUseCase,
    this._getRouteStopsForRouteUseCase,
  ) : super(const RouteStopsInitial());

  Future<void> loadRoutesForStop(BusStop stop) async {
    emit(const RouteStopsLoading());
    try {
      final routeIds = await _getRoutesForStopUseCase(stop.id);
      if (routeIds.isEmpty) {
        emit(
          RouteStopsLoaded(stop: stop, routes: const [], vehicles: const []),
        );
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
      final fiveMinutesAgo = DateTime.now().subtract(
        const Duration(minutes: 5),
      );
      updatedVehicles.removeWhere((v) => v.timestamp.isBefore(fiveMinutesAgo));
      updatedVehicles.sort((a, b) => a.routeId.compareTo(b.routeId));
      emit(currentState.copyWith(vehicles: updatedVehicles));
    }
  }

  /// Loads realistic route geometries for a route in both directions
  Future<void> loadRouteGeometries(String routeId) async {
    try {
      final outboundGeometry = await _getRouteGeometryUseCase(routeId, 0);
      final inboundGeometry = await _getRouteGeometryUseCase(routeId, 1);

      _routeGeometry = {};
      if (outboundGeometry.isNotEmpty) {
        _routeGeometry[0] =
            outboundGeometry
                .map((p) => osm.LatLng(p.latitude, p.longitude))
                .toList();
      }
      if (inboundGeometry.isNotEmpty) {
        _routeGeometry[1] =
            inboundGeometry
                .map((p) => osm.LatLng(p.latitude, p.longitude))
                .toList();
      }
      // Optionally emit a state update if you want to react to geometry changes
    } catch (e) {
      // Handle error if needed
    }
  }

  /// Get geometry for a direction, fallback to stops if not available
  List<osm.LatLng> getRouteGeometryForDirection(
    int direction,
    List<BusStop> stops,
  ) {
    // Chỉ trả về geometry đúng direction
    if (_routeGeometry.containsKey(direction) &&
        _routeGeometry[direction]!.isNotEmpty) {
      return _routeGeometry[direction]!;
    }
    // Fallback: chỉ lấy các stops đúng direction và đúng thứ tự sequence
    return stops.map((s) => osm.LatLng(s.latitude, s.longitude)).toList();
  }

  /// Lấy danh sách RouteStop cho một tuyến (dùng usecase, không gọi trực tiếp ở screen)
  Future<List<RouteStop>> getRouteStopsForRoute(String routeId) async {
    // Nếu đã cache có thể cache lại, ở đây luôn gọi mới
    return await _getRouteStopsForRouteUseCase(routeId);
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
