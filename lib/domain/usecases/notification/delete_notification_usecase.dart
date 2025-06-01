import 'package:injectable/injectable.dart';

import '../../repositories/notification_repository.dart';

@injectable
class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  DeleteNotificationUseCase(this._repository);

  Future<void> execute(String notificationId) {
    return _repository.deleteNotification(notificationId);
  }

  Future<void> executeAll() {
    return _repository.deleteAllNotifications();
  }
}
