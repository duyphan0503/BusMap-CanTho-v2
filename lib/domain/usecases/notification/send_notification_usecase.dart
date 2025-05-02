import '../../../data/model/notification.dart';
import '../../../data/repositories/notification_repository.dart';

class SendNotificationUseCase {
  final NotificationRepository _repo;

  SendNotificationUseCase(this._repo);

  Future<void> call(String userId, String message) =>
      _repo.sendNotification(userId, message);
}
