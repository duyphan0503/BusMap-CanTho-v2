import 'package:injectable/injectable.dart';

import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../model/notification.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;

  NotificationRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<AppNotification>> getUserNotifications() {
    return _remoteDatasource.getNotifications();
  }

  @override
  Future<void> notify({required String message}) {
    return _remoteDatasource.sendNotification(message);
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return _remoteDatasource.deleteNotification(notificationId);
  }

  @override
  Future<void> deleteAllNotifications() {
    return _remoteDatasource.deleteAllNotifications();
  }
}
