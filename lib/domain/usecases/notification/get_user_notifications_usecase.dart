import '../../../data/model/notification.dart';
import '../../../data/repositories/notification_repository.dart';

class GetUserNotificationsUseCase {
  final NotificationRepository repo;

  GetUserNotificationsUseCase(this.repo);

  Future<List<AppNotification>> call() =>
      repo.getUserNotifications();
}
