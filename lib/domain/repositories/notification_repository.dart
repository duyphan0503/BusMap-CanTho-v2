import '../../data/model/notification.dart';

abstract class NotificationRepository {
  Future<void> notify({required String message});

  Future<List<AppNotification>> getUserNotifications();

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteAllNotifications();
}
