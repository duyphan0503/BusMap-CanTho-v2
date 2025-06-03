import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
// Thêm import cho permission handler
import 'package:permission_handler/permission_handler.dart';

class NotificationLocalService {
  static final NotificationLocalService _instance = NotificationLocalService._internal();
  factory NotificationLocalService() => _instance;
  NotificationLocalService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Update to use user-specific notification keys
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Các kênh thông báo khác nhau
  static const String _generalChannel = 'default_channel';
  static const String _busApproachingChannel = 'bus_approaching_channel';
  static const String _busArrivedChannel = 'bus_arrived_channel';
  static const String _busDepartedChannel = 'bus_departed_channel';

  // Kiểm tra và yêu cầu quyền cho thông báo trên Android 13+
  Future<bool> _requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      // Check Android version
      final androidInfo = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.getNotificationAppLaunchDetails();

      if (androidInfo != null) {
        // Sử dụng permission_handler cho Android
        PermissionStatus status = await Permission.notification.status;
        if (!status.isGranted) {
          status = await Permission.notification.request();
        }
        return status.isGranted;
      }
    }
    return true;
  }

  Future<void> init(BuildContext context) async {
    // Thiết lập Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Thiết lập iOS nếu cần
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Xử lý khi người dùng tap vào thông báo
        debugPrint('Notification tapped: ${notificationResponse.payload}');
      },
    );

    // Yêu cầu quyền thông báo
    await _requestNotificationPermissions();

    // Đăng ký các kênh thông báo với Android
    await _setupNotificationChannels();
  }

  // Thiết lập các kênh thông báo cho Android
  Future<void> _setupNotificationChannels() async {
    // Kênh mặc định
    const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
      _generalChannel,
      'Thông báo',
      description: 'Kênh thông báo mặc định',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Kênh thông báo xe đến gần
    const AndroidNotificationChannel approachingChannel = AndroidNotificationChannel(
      _busApproachingChannel,
      'Thông báo xe đến gần',
      description: 'Thông báo khi xe buýt đang đến gần trạm',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Kênh thông báo xe đã đến
    const AndroidNotificationChannel arrivedChannel = AndroidNotificationChannel(
      _busArrivedChannel,
      'Thông báo xe đã đến',
      description: 'Thông báo khi xe buýt đã đến trạm',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Kênh thông báo xe đã rời đi
    const AndroidNotificationChannel departedChannel = AndroidNotificationChannel(
      _busDepartedChannel,
      'Thông báo xe đã rời đi',
      description: 'Thông báo khi xe buýt đã rời trạm',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(approachingChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(arrivedChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(departedChannel);
  }

  // Yêu cầu quyền cho iOS
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Thêm phương thức để kiểm tra xem thông báo có được bật hay không
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Mặc định cho phép thông báo nếu chưa có cài đặt
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  // Hiển thị thông báo với kênh mặc định
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Kiểm tra xem người dùng có tắt thông báo không
    final notificationsEnabled = await areNotificationsEnabled();
    if (!notificationsEnabled) {
      // Nếu thông báo đã bị tắt, không hiển thị thông báo
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _generalChannel,
      'Thông báo',
      channelDescription: 'Kênh thông báo mặc định',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon', // Sử dụng icon mặc định của ứng dụng
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    await saveNotification(title, body);
  }

  // Hiển thị thông báo với loại cụ thể dựa trên trạng thái xe buýt
  Future<void> showBusNotification({
    required String title,
    required String body,
    required String status, // 'approaching', 'arrived', 'departed'
    String? payload,
  }) async {
    // Kiểm tra xem người dùng có tắt thông báo không
    final notificationsEnabled = await areNotificationsEnabled();
    if (!notificationsEnabled) {
      // Nếu thông báo đã bị tắt, không hiển thị thông báo
      return;
    }

    late AndroidNotificationDetails androidDetails;

    switch (status) {
      case 'approaching':
        androidDetails = const AndroidNotificationDetails(
          _busApproachingChannel,
          'Thông báo xe đến gần',
          channelDescription: 'Thông báo khi xe buýt đang đến gần trạm',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon', // Sử dụng icon mặc định của ứng dụng
          color: Color(0xFF4CAF50), // Màu xanh lá
          showWhen: true,
        );
        break;

      case 'arrived':
        androidDetails = const AndroidNotificationDetails(
          _busArrivedChannel,
          'Thông báo xe đã đến',
          channelDescription: 'Thông báo khi xe buýt đã đến trạm',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/launcher_icon', // Sử dụng icon mặc định của ứng dụng
          color: Color(0xFF2196F3), // Màu xanh dương
          showWhen: true,
        );
        break;

      case 'departed':
        androidDetails = const AndroidNotificationDetails(
          _busDepartedChannel,
          'Thông báo xe đã rời đi',
          channelDescription: 'Thông báo khi xe buýt đã rời trạm',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon', // Sử dụng icon mặc định của ứng dụng
          color: Color(0xFFF44336), // Màu đỏ
          showWhen: true,
        );
        break;

      default:
        androidDetails = const AndroidNotificationDetails(
          _generalChannel,
          'Thông báo',
          channelDescription: 'Kênh thông báo mặc định',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher', // Sử dụng icon mặc định của ứng dụng
          showWhen: true,
        );
    }

    final NotificationDetails platformSpecifics = NotificationDetails(android: androidDetails);

    // Fix: Ensure the notification ID is within the 32-bit integer range
    // Use a combination of status hashcode and current time, but constrained to int32 range
    final int statusCode = status.hashCode;
    final int timeCode = DateTime.now().millisecondsSinceEpoch % 100000; // Use only the last 5 digits
    final int notificationId = (statusCode + timeCode) % 2147483647; // Ensure it's positive and within int32 max

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformSpecifics,
      payload: payload,
    );

    await saveNotification(title, body);
  }

  // Get current user ID
  String? _getCurrentUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  // Get notification key for current user
  String _getNotificationKeyForUser() {
    String? userId = _getCurrentUserId();
    return userId != null ? 'notifications_$userId' : 'notifications_guest';
  }

  Future<void> saveNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationKey = _getNotificationKeyForUser();
    final List<String> notifications = prefs.getStringList(notificationKey) ?? [];
    final String notification =
        '${DateTime.now().toIso8601String()}|$title|$body';
    notifications.add(notification);
    await prefs.setStringList(notificationKey, notifications);
  }

  Future<List<Map<String, String>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationKey = _getNotificationKeyForUser();
    final List<String> notifications = prefs.getStringList(notificationKey) ?? [];
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
    final notificationKey = _getNotificationKeyForUser();
    await prefs.remove(notificationKey);
  }

  Future<void> deleteNotification(String time) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationKey = _getNotificationKeyForUser();
    final List<String> notifications = prefs.getStringList(notificationKey) ?? [];
    notifications.removeWhere((notification) => notification.startsWith('$time|'));
    await prefs.setStringList(notificationKey, notifications);
  }
}
