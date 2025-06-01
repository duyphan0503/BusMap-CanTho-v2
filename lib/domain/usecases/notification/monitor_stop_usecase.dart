import 'dart:async';
import 'dart:math';

import 'package:busmapcantho/core/services/notification_local_service.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/bus_stop.dart';
import '../../../data/repositories/bus_location_repository.dart';

@injectable
class MonitorStopUseCase {
  final BusLocationRepository _busLocationRepo;
  final NotificationLocalService _notificationService;

  MonitorStopUseCase(this._busLocationRepo, this._notificationService);

  Stream<bool> execute({
    required BusStop stop,
    required double distanceThreshold,
    required String routeId,
  }) {
    final controller = StreamController<bool>();
    final subscription = _busLocationRepo
        .subscribeToBusLocations(routeId)
        .listen((locations) {
          for (final location in locations) {
            final distance = _calculateDistance(
              location.lat,
              location.lng,
              stop.latitude,
              stop.longitude,
            );

            if (distance <= distanceThreshold) {
              _notificationService.showNotification(
                title: 'Bus ${location.vehicleId} approaching',
                body: '${distance.toStringAsFixed(0)} m away',
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
