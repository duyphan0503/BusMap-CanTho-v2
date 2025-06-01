import 'dart:async';

import 'package:busmapcantho/domain/usecases/notification/get_user_notifications_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/bus_stop.dart';
import '../../../data/model/notification.dart';
import '../../../domain/usecases/notification/delete_notification_usecase.dart';
import '../../../domain/usecases/notification/monitor_stop_usecase.dart';
import '../../../domain/usecases/notification/report_vehicle_arrival_usecase.dart';

part 'notification_state.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final MonitorStopUseCase _monitorUseCase;
  final ReportVehicleArrivalUseCase _reportUseCase;
  final GetUserNotificationsUseCase _getNotificationsUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;

  StreamSubscription<bool>? _monitorSubscription;
  StreamSubscription<bool>? _reportSubscription;

  NotificationCubit(
    this._monitorUseCase,
    this._reportUseCase,
    this._getNotificationsUseCase,
    this._deleteNotificationUseCase,
  ) : super(NotificationInitial());

  Future<void> loadNotifications() async {
    try {
      emit(NotificationLoading());
      final notifications = await _getNotificationsUseCase.execute();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _deleteNotificationUseCase.execute(id);
      loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      emit(NotificationLoading());
      await _deleteNotificationUseCase.executeAll();
      emit(const NotificationLoaded([]));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> startMonitoring({
    required BusStop stop,
    required double distanceThreshold,
    required String routeId,
  }) async {
    try {
      _monitorSubscription?.cancel();
      emit(NotificationMonitoringInProgress());

      _monitorSubscription = _monitorUseCase
          .execute(
            stop: stop,
            distanceThreshold: distanceThreshold,
            routeId: routeId,
          )
          .listen(
            (isTriggered) {
              if (isTriggered) {
                emit(NotificationTriggered('Distance threshold reached'));
                loadNotifications(); // Reload notifications when triggered
              }
            },
            onError: (error) {
              emit(NotificationError(error.toString()));
            },
          );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> startReporting({
    required BusStop stop,
    required int timeThreshold,
    required String routeId,
  }) async {
    try {
      _reportSubscription?.cancel();
      emit(NotificationReportingInProgress());

      _reportSubscription = _reportUseCase
          .execute(
            stop: stop,
            timeThresholdMinutes: timeThreshold,
            routeId: routeId,
          )
          .listen(
            (isTriggered) {
              if (isTriggered) {
                emit(NotificationTriggered('Time threshold reached'));
                loadNotifications();
              }
            },
            onError: (error) {
              emit(NotificationError(error.toString()));
            },
          );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void stopAllNotifications() {
    _monitorSubscription?.cancel();
    _reportSubscription?.cancel();
    emit(NotificationInitial());
  }

  @override
  Future<void> close() {
    _monitorSubscription?.cancel();
    _reportSubscription?.cancel();
    return super.close();
  }
}
