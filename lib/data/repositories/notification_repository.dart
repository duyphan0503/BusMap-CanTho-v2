import 'package:injectable/injectable.dart';

import '../datasources/notification_remote_datasource.dart';
import '../model/notification.dart';

@lazySingleton
class NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;

  NotificationRepository(this._remoteDatasource);

  // Get notifications for the current authenticated user
  Future<List<AppNotification>> getUserNotifications() {
    return _remoteDatasource.getNotifications();
  }

  // Admin only - send notification to a specific user
  Future<void> sendNotification(String userId, String message) {
    return _remoteDatasource.sendNotification(userId, message);
  }
  
  Future<void> markNotificationAsRead(String notificationId) {
    return _remoteDatasource.markNotificationAsRead(notificationId);
  }
  
  Future<List<AppNotification>> getUserNotificationsByUserId(String userId) {
    throw UnimplementedError('Use getUserNotifications() instead');
  }
}
