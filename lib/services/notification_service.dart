import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Schedule daily notifications
    await scheduleDailyNotifications();
    
    // Register background task for consistency
    await Workmanager().registerPeriodicTask(
      'dailyNotifications',
      'showDailyReminders',
      frequency: const Duration(days: 1),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresCharging: false,
      ),
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<void> scheduleDailyNotifications() async {
    await _notificationsPlugin.cancelAll();

    // Morning notification
    await _scheduleNotification(
      id: 0,
      title: '🌅 Good Morning! Time to Study',
      body: 'Your IELTS morning session starts now. Today\'s focus: Writing excellence!',
      time: const Time(7, 0),
      payload: 'morning_session',
    );

    // Afternoon notification
    await _scheduleNotification(
      id: 1,
      title: '📚 Afternoon Study Time',
      body: 'Let\'s continue with your IELTS preparation. Reading comprehension awaits!',
      time: const Time(14, 0),
      payload: 'afternoon_session',
    );

    // Evening notification
    await _scheduleNotification(
      id: 2,
      title: '🌙 Evening Review',
      body: 'Time for vocabulary review and progress tracking. You\'re doing great!',
      time: const Time(20, 0),
      payload: 'evening_review',
    );

    // Progress check notification
    await _scheduleNotification(
      id: 3,
      title: '✨ Daily Progress Check',
      body: 'How was your study day? Log your progress and prepare for tomorrow!',
      time: const Time(21, 0),
      payload: 'progress_check',
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Time time,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ielts_study_channel',
          'IELTS Study Reminders',
          channelDescription: 'Daily study session reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(''),
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel',
        'Instant Notifications',
        channelDescription: 'Instant notifications for immediate feedback',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> showMilestoneNotification({
    required String milestone,
    required String achievement,
  }) async {
    await showInstantNotification(
      title: '🎉 Milestone Reached!',
      body: '$milestone: $achievement',
      payload: 'milestone',
    );
  }

  static Future<void> showMotivationalNotification() async {
    final motivationalMessages = [
      'Every expert was once a beginner. Keep going!',
      'Your future self will thank you for this effort!',
      'Band 8.0 is getting closer with each study session!',
      'Success is the sum of small efforts repeated daily!',
      'You\'re investing in your future - worth every minute!',
    ];

    final randomMessage = motivationalMessages[
        DateTime.now().millisecondsSinceEpoch % motivationalMessages.length];

    await showInstantNotification(
      title: '💪 Keep Going!',
      body: randomMessage,
      payload: 'motivation',
    );
  }

  static Future<void> showWeeklyProgressNotification({
    required int studyDays,
    required int totalWords,
    required double currentBand,
  }) async {
    await showInstantNotification(
      title: '📊 Weekly Progress Report',
      body: 'You studied $studyDays days, learned $totalWords words, and reached Band $currentBand!',
      payload: 'weekly_progress',
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> showDailyReminders() async {
    // This is called by the background task
    await scheduleDailyNotifications();
  }
}

class Time {
  final int hour;
  final int minute;

  const Time(this.hour, this.minute);
}
