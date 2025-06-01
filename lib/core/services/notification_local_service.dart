import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationLocalService {
  static final NotificationLocalService _instance = NotificationLocalService._internal();
  factory NotificationLocalService() => _instance;
  NotificationLocalService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _notificationKey = 'notifications';

  Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'Thông báo',
      channelDescription: 'Kênh thông báo mặc định',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
    await saveNotification(title, body);
  }

  Future<void> saveNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notifications = prefs.getStringList(_notificationKey) ?? [];
    final String notification =
        '${DateTime.now().toIso8601String()}|$title|$body';
    notifications.add(notification);
    await prefs.setStringList(_notificationKey, notifications);
  }

  Future<List<Map<String, String>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notifications = prefs.getStringList(_notificationKey) ?? [];
    return notifications.map((e) {
      final parts = e.split('|');
      return {
        'time': parts[0],
        'title': parts.length > 1 ? parts[1] : '',
        'body': parts.length > 2 ? parts[2] : '',
      };
    }).toList().reversed.toList();
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationKey);
  }
}

