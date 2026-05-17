import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:to_do_list/data/models/task_model.dart';
import 'package:to_do_list/data/models/task_status.dart';
import 'package:to_do_list/extensions/time_of_day_extensions.dart';

/// Service quản lý notifications cho ứng dụng To-Do List.
/// Sử dụng FCM để xin quyền và flutter_local_notifications
/// để schedule thông báo nhắc nhở trước 5 phút khi task bắt đầu.
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  /// Singleton instance
  static NotificationService get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Số phút nhắc nhở trước khi task bắt đầu
  static const int _reminderMinutesBefore = 5;

  /// Notification channel ID
  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Nhắc nhở công việc';
  static const String _channelDescription =
      'Thông báo nhắc nhở trước khi công việc bắt đầu';

  /// Khởi tạo toàn bộ notification system
  Future<void> initialize() async {
    // Khởi tạo timezone
    tz.initializeTimeZones();

    // Xin quyền notification qua FCM
    await _requestPermission();

    // Lấy FCM token (cho future server push nếu cần)
    await _getFcmToken();

    // Khởi tạo local notifications
    await _initLocalNotifications();

    // Lắng nghe FCM messages khi app đang foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    log('NotificationService initialized');
  }

  /// Xin quyền gửi notification
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('FCM permission status: ${settings.authorizationStatus}');
  }

  /// Lấy FCM token
  Future<String?> _getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      log('FCM Token: $token');
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  /// Khởi tạo flutter_local_notifications plugin
  Future<void> _initLocalNotifications() async {
    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Tạo notification channel cho Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Xử lý khi user tap vào notification
  void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    // Có thể navigate đến task detail ở đây nếu cần
  }

  /// Xử lý FCM message khi app đang foreground
  void _handleForegroundMessage(RemoteMessage message) {
    log('FCM foreground message: ${message.notification?.title}');
  }

  /// Schedule notification nhắc nhở trước 5 phút cho một task
  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (task.id == null) return;

    // Không schedule cho task đã hoàn thành
    if (task.status == TaskStatus.complete) return;

    // Tính thời gian bắt đầu task
    final taskStartDateTime = task.startTime.toDateTime(task.date);

    // Thời gian nhắc nhở = startTime - 5 phút
    final reminderTime =
        taskStartDateTime.subtract(Duration(minutes: _reminderMinutesBefore));

    // Không schedule nếu thời gian nhắc nhở đã qua
    if (reminderTime.isBefore(DateTime.now())) {
      log('Skipping reminder for "${task.name}" - time already passed');
      return;
    }

    // Chuyển sang TZDateTime
    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    // Notification ID từ taskId hashCode
    final notificationId = task.id.hashCode;

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotificationsPlugin.zonedSchedule(
      notificationId,
      '⏰ Sắp đến giờ!',
      '"${task.name}" sẽ bắt đầu trong $_reminderMinutesBefore phút nữa',
      tzReminderTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );

    log('Scheduled reminder for "${task.name}" at $reminderTime');
  }

  /// Hủy notification cho một task
  Future<void> cancelTaskReminder(String taskId) async {
    final notificationId = taskId.hashCode;
    await _localNotificationsPlugin.cancel(notificationId);
    log('Cancelled reminder for task: $taskId');
  }

  /// Hủy tất cả notification và schedule lại cho tất cả task
  /// Được gọi mỗi khi Firestore stream emit data mới
  Future<void> rescheduleAllReminders(List<TaskModel> tasks) async {
    // Hủy tất cả notifications hiện tại
    await _localNotificationsPlugin.cancelAll();

    // Schedule lại cho các task chưa hoàn thành
    int scheduledCount = 0;
    for (final task in tasks) {
      if (task.status == TaskStatus.incomplete && task.id != null) {
        final taskStartDateTime = task.startTime.toDateTime(task.date);
        final reminderTime = taskStartDateTime
            .subtract(Duration(minutes: _reminderMinutesBefore));

        // Chỉ schedule nếu thời gian nhắc nhở chưa qua
        if (reminderTime.isAfter(DateTime.now())) {
          await scheduleTaskReminder(task);
          scheduledCount++;
        }
      }
    }

    log('Rescheduled $scheduledCount reminders for ${tasks.length} tasks');
  }
}
