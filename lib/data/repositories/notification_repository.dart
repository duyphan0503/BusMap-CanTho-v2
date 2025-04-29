import 'package:busmapcantho/data/datasources/notification_remote_datasource.dart';

import '../model/notification.dart';

class NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;

  NotificationRepository([NotificationRemoteDatasource? remoteDatasource])
    : _remoteDatasource = remoteDatasource ?? NotificationRemoteDatasource();

  Future<List<AppNotification>> getUserNotifications(String userId) {
    return _remoteDatasource.getUserNotifications(userId);
  }

  Future<void> sendNotification(AppNotification notification) {
    return _remoteDatasource.sendNotification(notification);
  }
}