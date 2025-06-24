import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection.dart';
import '../model/notification.dart';

@lazySingleton
class NotificationRemoteDatasource {
  final SupabaseClient _client;

  NotificationRemoteDatasource(this._client);

  Future<List<AppNotification>> getNotifications() async {
    final logger = getIt<Logger>();
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception(tr('errorUserNotLoggedIn'));
      }

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('sent_at', ascending: false);

      return response.map((data) => AppNotification.fromJson(data)).toList();
    } catch (e, stack) {
      logger.e('Failed to load notifications', error: e, stackTrace: stack);
      throw Exception(tr('errorLoadingNotifications'));
    }
  }

  // Only for admin users
  Future<void> sendNotification(String message) async {
    final logger = getIt<Logger>();
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception(tr('errorUserNotLoggedIn'));
      }
      await _client.from('notifications').insert({
        'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user.id,
        'message': message,
        'sent_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      logger.e('Failed to send notification', error: e, stackTrace: stack);
      throw Exception(tr('errorSendNotification'));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final logger = getIt<Logger>();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(tr('errorUserNotLoggedIn'));
      }

      await _client.from('notifications').delete().match({
        'id': notificationId,
        'user_id': userId,
      });
    } catch (e, stack) {
      logger.e('Failed to delete notification', error: e, stackTrace: stack);
      throw Exception(tr('errorDeleteNotification'));
    }
  }

  Future<void> deleteAllNotifications() async {
    final logger = getIt<Logger>();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(tr('errorUserNotLoggedIn'));
      }

      await _client.from('notifications').delete().match({'user_id': userId});
    } catch (e, stack) {
      logger.e(
        'Failed to delete all notifications',
        error: e,
        stackTrace: stack,
      );
      throw Exception(tr('errorDeleteAllNotifications'));
    }
  }
}
