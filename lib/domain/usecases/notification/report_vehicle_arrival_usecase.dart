import 'dart:async';
import 'dart:math';

import 'package:busmapcantho/core/services/notification_local_service.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/bus_location.dart';
import '../../../data/model/bus_stop.dart';
import '../../../data/repositories/bus_location_repository.dart';

@injectable
class ReportVehicleArrivalUseCase {
  final BusLocationRepository _busLocationRepo;
  final NotificationLocalService _notificationService;

  ReportVehicleArrivalUseCase(this._busLocationRepo, this._notificationService);

  Stream<bool> execute({
    required BusStop stop,
    required int timeThresholdMinutes,
    required String routeId,
  }) {
    final controller = StreamController<bool>();
    final subscription = _busLocationRepo
        .subscribeToBusLocations(routeId)
        .listen((locations) {
          for (final location in locations) {
            final eta = _calculateETA(
              currentLocation: location,
              targetStop: stop,
            );

            if (eta <= timeThresholdMinutes) {
              _notificationService.showNotification(
                title: 'Bus ${location.vehicleId} ETA',
                body: '${eta.toStringAsFixed(1)} minutes',
              );
              controller.add(true);
              return;
            }
          }
          controller.add(false);
        });

    controller.onCancel = subscription.cancel;
    return controller.stream;
  }

  double _calculateETA({
    required BusLocation currentLocation,
    required BusStop targetStop,
  }) {
    final distance = _calculateDistance(
      currentLocation.lat,
      currentLocation.lng,
      targetStop.latitude,
      targetStop.longitude,
    );

    // Convert m/s to km/h and handle zero speed
    final speed = currentLocation.speed > 0 ? currentLocation.speed : 10.0;
    return (distance / speed) / 60; // in minutes
  }

  // Reuse distance calculation from MonitorStopUseCase
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const R = 6371000.0; // Radius of the Earth in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
