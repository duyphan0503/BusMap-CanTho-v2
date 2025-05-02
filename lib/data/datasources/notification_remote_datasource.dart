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
  Future<void> sendNotification(String userId, String message) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'message': message,
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // If your schema doesn't have a 'read' field, you'd need to add it
      // This example assumes you have or will add such a field
      await _client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
