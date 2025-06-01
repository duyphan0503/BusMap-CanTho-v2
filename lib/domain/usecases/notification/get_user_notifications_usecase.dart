import 'package:busmapcantho/domain/repositories/notification_repository.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/notification.dart';

@injectable
class GetUserNotificationsUseCase {
  final NotificationRepository _repo;

  GetUserNotificationsUseCase(this._repo);

  Future<List<AppNotification>> execute() {
    return _repo.getUserNotifications();
  }
}
