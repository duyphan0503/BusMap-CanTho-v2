import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
  }

  static Future<void> showNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'bus_channel',
      'Bus Notifications',
      channelDescription: 'Notifications for bus arrival and departure',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}
