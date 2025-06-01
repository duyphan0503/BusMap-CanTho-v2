part of 'notification_cubit.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;

  const NotificationLoaded(this.notifications);
}

class NotificationMonitoringInProgress extends NotificationState {}

class NotificationReportingInProgress extends NotificationState {}

class NotificationTriggered extends NotificationState {
  final String message;

  NotificationTriggered(this.message);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
