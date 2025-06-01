import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/notification.dart';

@lazySingleton
class NotificationRemoteDatasource {
  final SupabaseClient _client;

  NotificationRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to get notifications');
      }

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('sent_at', ascending: false);
      
      return response.map((data) => AppNotification.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Only for admin users
  Future<void> sendNotification(String message) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to get notifications');
      }
      await _client.from('notifications').insert({
        'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user.id,
        'message': message,
        'sent_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .from('notifications')
        .delete()
        .match({'id': notificationId, 'user_id': userId});
  }

  Future<void> deleteAllNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .from('notifications')
        .delete()
        .match({'user_id': userId});
  }
}
