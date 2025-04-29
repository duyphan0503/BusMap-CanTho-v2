import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/notification.dart';

class NotificationRemoteDatasource {
  final SupabaseClient _client;

  NotificationRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  Future<List<AppNotification>> getUserNotifications(String userId) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('sent_at', ascending: false);
    return (response as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> sendNotification(AppNotification notification) async {
    await _client.from('notifications').insert(notification.toJson());
  }
}