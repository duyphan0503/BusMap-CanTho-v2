import 'package:injectable/injectable.dart';

import '../services/notification_local_service.dart';

@module
abstract class NotificationModule {
  @lazySingleton
  NotificationLocalService get notificationLocalService =>
      NotificationLocalService();
}