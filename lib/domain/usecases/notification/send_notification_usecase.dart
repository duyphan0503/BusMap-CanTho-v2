import '../../../data/model/notification.dart';
import '../../../data/repositories/notification_repository.dart';

class SendNotificationUseCase {
  final NotificationRepository _repo;

  SendNotificationUseCase(this._repo);

  Future<void> call(AppNotification notification) =>
      _repo.sendNotification(notification);
}
