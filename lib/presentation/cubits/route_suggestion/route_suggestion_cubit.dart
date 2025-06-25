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

  // Trích xuất khoảng cách từ chuỗi (ví dụ: "500 m" hoặc "1.2 km") thành số mét
  double _extractDistance(String distanceStr) {
    try {
      // Loại bỏ dấu cách và chuyển về chữ thường
      final cleanStr = distanceStr.toLowerCase().replaceAll(' ', '');

      // Tìm số trong chuỗi
      final numMatch = RegExp(r'(\d+[.,]?\d*)').firstMatch(cleanStr);
      if (numMatch == null) return 0;

      final numStr = numMatch.group(1)!.replaceAll(',', '.');
      final distance = double.parse(numStr);

      // Xác định đơn vị (m hoặc km)
      if (cleanStr.contains('km')) {
        return distance * 1000; // Chuyển km thành mét
      } else {
        return distance; // Giả sử mặc định là mét
      }
    } catch (e) {
      return 0;
    }
  }

  // Tính thời gian đi bộ dựa trên khoảng cách (tốc độ đi bộ trung bình 5 km/h = 83m/phút)
  String _calculateWalkingTime(double distanceMeters) {
    if (distanceMeters <= 0) return '1 phút';
    final minutes = (distanceMeters / 83).ceil();

    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '$hours giờ $remainingMinutes phút'
          : '$hours giờ';
    }
  }

  // Tính thời gian đi xe buýt dựa trên khoảng cách (tốc độ trung bình 25 km/h = 417m/phút)
  String _calculateBusTime(double distanceMeters) {
    if (distanceMeters <= 0) return '5 phút';
    final minutes = (distanceMeters / 417).ceil();

    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '$hours giờ $remainingMinutes phút'
          : '$hours giờ';
    }
  }

  // Tính thời gian di chuyển đến trạm cuối cùng và điểm đích
  String _calculateEndWalkingTime(double distanceMeters) {
    // Giả định khoảng cách đi bộ trung bình từ trạm xe buýt đến đích là 400m
    if (distanceMeters <= 0) distanceMeters = 400;
    return _calculateWalkingTime(distanceMeters);
  }

  Future<void> _initializeSuggestions() async {
    emit(state.copyWith(isLoading: true, isBusActive: false));

    // Quyết định điểm xuất phát: nếu không có startLatLng, sử dụng vị trí hiện tại
    LatLng startPointLatLng;
    if (state.startLatLng != null) {
      // Sử dụng điểm bắt đầu đã được chọn
      startPointLatLng = state.startLatLng!;
    } else {
      // Sử dụng vị trí hiện tại nếu không có điểm bắt đầu
      final pos = await Geolocator.getCurrentPosition();
      startPointLatLng = LatLng(pos.latitude, pos.longitude);
    }

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

    if (state.endLatLng != null) {
      final endLatLng = state.endLatLng!;
      final int maxSegments = state.maxRoutes;
      List<Map<String, dynamic>> journeySegments = [];
      LatLng currentStartPoint = startPointLatLng;

      for (int i = 0; i < maxSegments; i++) {
        // 1. Lấy nhiều trạm gần điểm bắt đầu (điểm đã chọn hoặc vị trí hiện tại)
        final nearbyStops = await _getNearbyBusStopsUseCase(
          currentStartPoint.latitude,
          currentStartPoint.longitude,
          radiusInMeters: 3000,
          limit: 5,
          offset: 0,
        );
        BusStop? userNearestStop;
        if (nearbyStops.isNotEmpty) {
          const Distance distance = Distance();
          nearbyStops.sort((a, b) {
            final dA = distance(
              currentStartPoint,
              LatLng(a.latitude, a.longitude),
            );
            final dB = distance(
              currentStartPoint,
              LatLng(b.latitude, b.longitude),
            );
            return dA.compareTo(dB);
          });
          userNearestStop = nearbyStops.first;
        } else {
          userNearestStop = null;
        }

        if (userNearestStop == null) {
          break; // No more routes can be found
        }

        // 2. Lấy tất cả tuyến buýt
        final allRoutes = await _getAllBusRoutesUseCase();

        BusRoute? bestRoute;
        BusStop? bestStartStop;
        BusStop? bestEndStop;
        int bestDirection = 0;
        double minEndDist = double.infinity;

        // 3. Chỉ lấy các tuyến có chứa trạm gần user nhất
        for (final route in allRoutes) {
          for (final direction in [0, 1]) {
            // Lấy danh sách các trạm của tuyến này bằng usecase
            final routeStops = await _getRouteStopsAsBusStopsUseCase(
              route.id,
              direction,
            );
            if (routeStops.isEmpty) continue;

            final startIdx = routeStops.indexWhere(
              (stop) => stop.id == userNearestStop?.id,
            );
            if (startIdx == -1) continue;

            // 4. Tìm điểm dừng trên tuyến gần điểm đích nhất (sau điểm lên)
            BusStop? nearestEndStop;
            double minDist = double.infinity;
            for (int j = startIdx + 1; j < routeStops.length; j++) {
              final stop = routeStops[j];
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
              bestDirection = direction;
            }
          }
        }

        if (bestRoute != null && bestStartStop != null && bestEndStop != null) {
          final hasActiveBus = await _hasActiveBusOnRoute(bestRoute.id);
          isBusActive = isBusActive || hasActiveBus;

          if (hasActiveBus) {
            journeySegments.add({
              'route': bestRoute,
              'startStop': bestStartStop,
              'endStop': bestEndStop,
              'startPoint': currentStartPoint,
              'direction': bestDirection,
            });
            currentStartPoint = LatLng(
              bestEndStop.latitude,
              bestEndStop.longitude,
            );

            // If this segment's end stop is close enough to the final destination, stop searching.
            final distanceToEnd = const Distance().as(
              LengthUnit.Meter,
              currentStartPoint,
              endLatLng,
            );
            if (distanceToEnd < 1000) {
              // 1km threshold
              break;
            }
          } else {
            break; // If a segment has no active bus, the journey is not viable.
          }
        } else {
          break; // No more routes found
        }
      }

      if (journeySegments.isNotEmpty) {
        // Common calculations for both single and multi-segment
        List<Map<String, dynamic>> segmentDetails = [];
        double totalWalkingDistance = 0;
        double totalBusDistance = 0;
        double totalTime = 0;

        for (int i = 0; i < journeySegments.length; i++) {
          final segment = journeySegments[i];
          final route = segment['route'] as BusRoute;
          final startStop = segment['startStop'] as BusStop;
          final endStop = segment['endStop'] as BusStop;
          final segmentStartPoint = segment['startPoint'] as LatLng;

          final walkingDistanceMeters = const Distance().as(
            LengthUnit.Meter,
            segmentStartPoint,
            LatLng(startStop.latitude, startStop.longitude),
          );
          final busDistanceMeters = const Distance().as(
            LengthUnit.Meter,
            LatLng(startStop.latitude, startStop.longitude),
            LatLng(endStop.latitude, endStop.longitude),
          );

          totalWalkingDistance += walkingDistanceMeters;
          totalBusDistance += busDistanceMeters;

          final walkingTimeMin = (walkingDistanceMeters / 1000) / 5 * 60;
          final busTimeMin = (busDistanceMeters / 1000) / 25 * 60;
          totalTime += walkingTimeMin + busTimeMin;

          segmentDetails.add({
            'routeId': route.id,
            'direction': segment['direction'],
            'routeNumber': route.routeNumber,
            'routeName': route.routeName,
            'startStopName': startStop.name,
            'startStopId': startStop.id,
            'endStopName': endStop.name,
            'endStopId': endStop.id,
            'walkingDistance':
                walkingDistanceMeters < 1000
                    ? '${walkingDistanceMeters.round()} m'
                    : '${(walkingDistanceMeters / 1000).toStringAsFixed(2)} km',
            'busDistance':
                busDistanceMeters < 1000
                    ? '${busDistanceMeters.round()} m'
                    : '${(busDistanceMeters / 1000).toStringAsFixed(2)} km',
            'walkingTime': _calculateWalkingTime(walkingDistanceMeters),
            'busTime': _calculateBusTime(busDistanceMeters),
            'fare': route.fareInfo,
          });
        }

        final lastSegmentEndStop = journeySegments.last['endStop'] as BusStop;
        final endWalkingDistanceMeters = const Distance().as(
          LengthUnit.Meter,
          LatLng(lastSegmentEndStop.latitude, lastSegmentEndStop.longitude),
          endLatLng,
        );
        totalWalkingDistance += endWalkingDistanceMeters;
        final endWalkingTimeMin = (endWalkingDistanceMeters / 1000) / 5 * 60;
        totalTime += endWalkingTimeMin;

        String totalTimeStr;
        if (totalTime < 60) {
          totalTimeStr = '${totalTime.round()} phút';
        } else {
          final hours = totalTime ~/ 60;
          final minutes = totalTime % 60;
          totalTimeStr =
              minutes > 0 ? '$hours giờ ${minutes.round()} phút' : '$hours giờ';
        }

        final firstSegment = journeySegments.first;
        final startStopName = (firstSegment['startStop'] as BusStop).name;
        final endStopName = (lastSegmentEndStop).name;

        final commonExtra = {
          'totalTime': totalTimeStr,
          'startStopName': startStopName,
          'endStopName': endStopName,
          'walkingDistance':
              totalWalkingDistance < 1000
                  ? '${totalWalkingDistance.round()} m'
                  : '${(totalWalkingDistance / 1000).toStringAsFixed(2)} km',
          'busDistance':
              totalBusDistance < 1000
                  ? '${totalBusDistance.round()} m'
                  : '${(totalBusDistance / 1000).toStringAsFixed(2)} km',
          'endWalkingDistance':
              endWalkingDistanceMeters < 1000
                  ? '${endWalkingDistanceMeters.round()} m'
                  : '${(endWalkingDistanceMeters / 1000).toStringAsFixed(2)} km',
          'endWalkingTime': _calculateEndWalkingTime(endWalkingDistanceMeters),
        };

        if (journeySegments.length > 1) {
          // Multi-segment journey
          final representativeRoute = firstSegment['route'] as BusRoute;
          final journeyRoute = BusRoute(
            id: representativeRoute.id,
            routeNumber: journeySegments
                .map((s) => (s['route'] as BusRoute).routeNumber)
                .join(' -> '),
            routeName: 'Hành trình gồm ${journeySegments.length} chặng',
            description: 'Chi tiết trong phần hướng dẫn',
            operatingHoursDescription:
                representativeRoute.operatingHoursDescription,
            frequencyDescription: representativeRoute.frequencyDescription,
            fareInfo: representativeRoute.fareInfo,
            routeType: representativeRoute.routeType,
            agencyId: representativeRoute.agencyId,
            createdAt: representativeRoute.createdAt,
            updatedAt: representativeRoute.updatedAt,
            stops: [],
            extra: {
              ...commonExtra,
              'segments': segmentDetails,
              'isMultiSegment': true,
            },
          );
          routes = [journeyRoute];
        } else {
          // Single-segment journey
          final segment = journeySegments.first;
          final route = segment['route'] as BusRoute;
          final initialWalkingDistance =
              totalWalkingDistance - endWalkingDistanceMeters;

          final singleRoute = BusRoute(
            id: route.id,
            routeNumber: route.routeNumber,
            routeName: route.routeName,
            description: route.description,
            operatingHoursDescription: route.operatingHoursDescription,
            frequencyDescription: route.frequencyDescription,
            fareInfo: route.fareInfo,
            routeType: route.routeType,
            agencyId: route.agencyId,
            createdAt: route.createdAt,
            updatedAt: route.updatedAt,
            stops: [],
            extra: {
              ...commonExtra,
              'walkingTime': _calculateWalkingTime(initialWalkingDistance),
              'busTime': _calculateBusTime(totalBusDistance),
              'isMultiSegment': false,
            },
          );
          routes = [singleRoute];
        }
      } else {
        routes = [];
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
    int? maxRoutes,
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
        maxRoutes: maxRoutes,
      ),
    );
    _initializeSuggestions();
  }

  Future<List<BusStop>> getRouteStops(
    String routeId, [
    int direction = 0,
  ]) async {
    try {
      return await _getRouteStopsAsBusStopsUseCase(routeId, direction);
    } catch (_) {
      return [];
    }
  }
}
