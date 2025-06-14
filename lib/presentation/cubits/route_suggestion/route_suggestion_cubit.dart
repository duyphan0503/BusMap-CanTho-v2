import 'dart:async';

import 'package:busmapcantho/domain/usecases/bus_stops/get_nearby_bus_stops_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/bus_realtime_service.dart';
import '../../../data/model/bus_route.dart';
import '../../../data/model/bus_stop.dart';
import '../../../domain/usecases/bus_routes/get_all_bus_routes_usecase.dart';
import '../../../domain/usecases/route_stops/get_route_stops_as_bus_stops_usecase.dart';
import 'route_suggestion_state.dart';

@injectable
class RouteSuggestionCubit extends Cubit<RouteSuggestionState> {
  final GetAllBusRoutesUseCase _getAllBusRoutesUseCase;
  final BusRealtimeService _busRealtimeService;
  final GetNearbyBusStopsUseCase _getNearbyBusStopsUseCase;
  final GetRouteStopsAsBusStopsUseCase _getRouteStopsAsBusStopsUseCase;

  RouteSuggestionCubit(
    this._getAllBusRoutesUseCase,
    this._busRealtimeService,
    this._getNearbyBusStopsUseCase,
    this._getRouteStopsAsBusStopsUseCase,
  ) : super(RouteSuggestionState(isLoading: true)) {
    _initializeSuggestions();
  }

  Future<bool> _hasActiveBusOnRoute(String routeId) async {
    try {
      final stream = _busRealtimeService.subscribeToBusLocations(routeId);
      final completer = Completer<bool>();
      late StreamSubscription sub;
      sub = stream.listen((_) {
        if (!completer.isCompleted) {
          completer.complete(true);
          sub.cancel();
        }
      });
      final result = await Future.any([
        completer.future,
        Future.delayed(const Duration(seconds: 2), () => false),
      ]);
      await sub.cancel();
      return result == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _initializeSuggestions() async {
    emit(state.copyWith(isLoading: true, isBusActive: false));

    final pos = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(pos.latitude, pos.longitude);

    double? calculatedDistance;
    if (state.startLatLng != null && state.endLatLng != null) {
      const distance = Distance();
      calculatedDistance = distance.as(
        LengthUnit.Kilometer,
        state.startLatLng!,
        state.endLatLng!,
      );
    }

    List<BusRoute> routes = [];
    bool isBusActive = false;

    if (state.startLatLng != null && state.endLatLng != null) {
      final startLatLng = state.startLatLng!;
      final endLatLng = state.endLatLng!;

      // 1. Lấy nhiều trạm gần user nhất bằng usecase, tự sort ở client
      final nearbyStops = await _getNearbyBusStopsUseCase(
        userLatLng.latitude,
        userLatLng.longitude,
        radiusInMeters: 3000,
        limit: 5, // lấy nhiều hơn 1 trạm
        offset: 0,
      );
      BusStop? userNearestStop;
      if (nearbyStops.isNotEmpty) {
        const Distance distance = Distance();
        nearbyStops.sort((a, b) {
          final dA = distance(userLatLng, LatLng(a.latitude, a.longitude));
          final dB = distance(userLatLng, LatLng(b.latitude, b.longitude));
          return dA.compareTo(dB);
        });
        userNearestStop = nearbyStops.first;
      } else {
        userNearestStop = null;
      }

      if (userNearestStop == null) {
        emit(state.copyWith(isLoading: false, suggestedBusRoutes: []));
        return;
      }

      // 2. Lấy tất cả tuyến buýt
      final allRoutes = await _getAllBusRoutesUseCase();

      BusRoute? bestRoute;
      BusStop? bestStartStop;
      BusStop? bestEndStop;
      double minEndDist = double.infinity;

      // 3. Chỉ lấy các tuyến có chứa trạm gần user nhất
      for (final route in allRoutes) {
        // Lấy danh sách các trạm của tuyến này bằng usecase
        final routeStops = await _getRouteStopsAsBusStopsUseCase(
          route.id,
          0,
        ); // direction = 0 (hoặc tuỳ logic)
        final startIdx = routeStops.indexWhere(
          (stop) => stop.id == userNearestStop?.id,
        );
        if (startIdx == -1) continue;

        // 4. Tìm điểm dừng trên tuyến gần điểm đích nhất (sau điểm lên)
        BusStop? nearestEndStop;
        double minDist = double.infinity;
        for (int i = startIdx + 1; i < routeStops.length; i++) {
          final stop = routeStops[i];
          final stopLatLng = LatLng(stop.latitude, stop.longitude);
          final d = const Distance().as(
            LengthUnit.Meter,
            endLatLng,
            stopLatLng,
          );
          if (d < minDist) {
            minDist = d;
            nearestEndStop = stop;
          }
        }
        if (nearestEndStop == null) continue;

        if (minDist < minEndDist) {
          minEndDist = minDist;
          bestRoute = route;
          bestStartStop = routeStops[startIdx];
          bestEndStop = nearestEndStop;
        }
      }

      if (bestRoute != null && bestStartStop != null && bestEndStop != null) {
        final hasActiveBus = await _hasActiveBusOnRoute(bestRoute.id);
        isBusActive = hasActiveBus;
        if (hasActiveBus) {
          final walkingDistanceMeters = const Distance().as(
            LengthUnit.Meter,
            startLatLng,
            LatLng(bestStartStop.latitude, bestStartStop.longitude),
          );
          final busDistanceMeters = const Distance().as(
            LengthUnit.Meter,
            LatLng(bestStartStop.latitude, bestStartStop.longitude),
            LatLng(bestEndStop.latitude, bestEndStop.longitude),
          );
          final walkingDistanceStr =
              walkingDistanceMeters < 1000
                  ? '${walkingDistanceMeters.round()} m'
                  : '${(walkingDistanceMeters / 1000).toStringAsFixed(2)} km';
          final busDistanceStr =
              busDistanceMeters < 1000
                  ? '${busDistanceMeters.round()} m'
                  : '${(busDistanceMeters / 1000).toStringAsFixed(2)} km';
          final walkingTimeMin = (walkingDistanceMeters / 1000) / 5 * 60;
          final busTimeMin = (busDistanceMeters / 1000) / 25 * 60;
          final totalTimeMin = walkingTimeMin + busTimeMin;
          String totalTimeStr;
          if (totalTimeMin < 60) {
            totalTimeStr = '${totalTimeMin.round()} phút';
          } else {
            final hours = totalTimeMin ~/ 60;
            final minutes = totalTimeMin % 60;
            totalTimeStr =
                minutes > 0 ? '$hours giờ $minutes phút' : '$hours giờ';
          }
          final demoRoute = BusRoute(
            id: bestRoute.id,
            routeNumber: bestRoute.routeNumber,
            routeName: bestRoute.routeName,
            description: bestRoute.description,
            operatingHoursDescription: bestRoute.operatingHoursDescription,
            frequencyDescription: bestRoute.frequencyDescription,
            fareInfo: bestRoute.fareInfo,
            routeType: bestRoute.routeType,
            agencyId: bestRoute.agencyId,
            createdAt: bestRoute.createdAt,
            updatedAt: bestRoute.updatedAt,
            stops: [],
            extra: {
              'walkingDistance': walkingDistanceStr,
              'busDistance': busDistanceStr,
              'totalTime': totalTimeStr,
              'startStopName': bestStartStop.name,
              'endStopName': bestEndStop.name,
            },
          );
          routes = [demoRoute];
        } else {
          routes = [];
        }
      }
    }

    emit(
      state.copyWith(
        distanceInKm: calculatedDistance,
        suggestedBusRoutes: routes,
        isLoading: false,
        isBusActive: isBusActive,
      ),
    );
  }

  void updateRouteParameters({
    LatLng? startLatLng,
    String? startName,
    LatLng? endLatLng,
    String? endName,
  }) {
    emit(
      state.copyWith(
        startLatLng: startLatLng,
        startName: startName,
        endLatLng: endLatLng,
        endName: endName,
        isLoading: true,
        suggestedBusRoutes: [],
        distanceInKm: null,
      ),
    );
    _initializeSuggestions();
  }

  Future<List<BusStop>> getRouteStops(String routeId) async {
    try {
      return await _getRouteStopsAsBusStopsUseCase(routeId, 0);
    } catch (_) {
      return [];
    }
  }
}
