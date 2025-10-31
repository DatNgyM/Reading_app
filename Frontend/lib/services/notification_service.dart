import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Initialize notifications
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to daily reading screen
    print('Notification tapped: ${response.payload}');
  }

  // Request all necessary permissions
  Future<bool> requestPermissions() async {
    // Request notification permission
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    // Android 13+ needs POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.request();

      // Android 12+ needs exact alarm permission
      if (Platform.isAndroid) {
        try {
          // Check if exact alarm permission is available
          final alarmStatus = await Permission.scheduleExactAlarm.status;

          if (!alarmStatus.isGranted) {
            // Open system settings to allow exact alarms
            final granted = await Permission.scheduleExactAlarm.request();

            if (!granted.isGranted) {
              // Fallback: open app settings manually
              await openAppSettings();
              return false;
            }
          }
        } catch (e) {
          print('Exact alarm permission error: $e');
        }
      }

      return notificationStatus.isGranted;
    }

    return true;
  }

  // Check if exact alarms are permitted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidImpl = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        return await androidImpl.canScheduleExactNotifications() ?? false;
      }
    } catch (e) {
      print('Check exact alarms error: $e');
    }

    return false;
  }

  // Request permission before scheduling (iOS)
  Future<bool> requestPermission() async {
    return await requestPermissions();
  }

  // Schedule daily notification
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await init();

    // Check and request exact alarm permission for Android
    if (Platform.isAndroid) {
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        // Request permission
        final androidImpl =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          await androidImpl.requestExactAlarmsPermission();
        }

        // Re-check
        final canScheduleNow = await canScheduleExactAlarms();
        if (!canScheduleNow) {
          throw Exception(
              'Không thể lên lịch thông báo chính xác. Vui lòng cấp quyền trong Cài đặt.');
        }
      }
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0, // notification id
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reading_channel',
          'Bài đọc hàng ngày',
          channelDescription: 'Thông báo nhắc nhở đọc Kinh Thánh hàng ngày',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    // Save settings
    await _saveNotificationSettings(hour, minute, true);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    await _saveNotificationSettings(0, 0, false);
  }

  // Save notification settings to SharedPreferences
  Future<void> _saveNotificationSettings(
      int hour, int minute, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notification_settings',
      json.encode({
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      }),
    );
  }

  // Load notification settings
  Future<Map<String, dynamic>> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('notification_settings');

    if (settingsJson == null) {
      return {
        'enabled': false,
        'hour': 7,
        'minute': 0,
      };
    }

    return json.decode(settingsJson) as Map<String, dynamic>;
  }

  // Check if notifications are enabled
  Future<bool> isEnabled() async {
    final settings = await loadNotificationSettings();
    return settings['enabled'] ?? false;
  }

  // Get scheduled notification time
  Future<Map<String, int>> getScheduledTime() async {
    final settings = await loadNotificationSettings();
    return {
      'hour': settings['hour'] ?? 7,
      'minute': settings['minute'] ?? 0,
    };
  }

  // Check if there are pending notifications
  Future<bool> hasPendingNotifications() async {
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();
    return pendingNotifications.isNotEmpty;
  }

  // Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Get detailed notification info
  Future<Map<String, dynamic>> getNotificationStatus() async {
    final pending = await _notifications.pendingNotificationRequests();
    final settings = await loadNotificationSettings();

    return {
      'isEnabled': settings['enabled'] ?? false,
      'hasPending': pending.isNotEmpty,
      'pendingCount': pending.length,
      'scheduledTime': {
        'hour': settings['hour'] ?? 7,
        'minute': settings['minute'] ?? 0,
      },
      'nextNotification': pending.isNotEmpty
          ? 'ID: ${pending.first.id}, Title: ${pending.first.title}'
          : 'Không có thông báo nào được lên lịch',
    };
  }

  // Test notification (send immediately)
  Future<void> sendTestNotification() async {
    await init();

    await _notifications.show(
      999, // test notification id
      'Thông báo thử nghiệm',
      'Đây là thông báo thử nghiệm. Nếu bạn thấy thông báo này, nghĩa là hệ thống đang hoạt động!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Thử nghiệm',
          channelDescription: 'Kênh thử nghiệm thông báo',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
