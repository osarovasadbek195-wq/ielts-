import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

class RealNotificationService {
  static final RealNotificationService _instance = RealNotificationService._internal();
  factory RealNotificationService() => _instance;
  RealNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'ielts_sat_channel',
        'IELTS & SAT Prep',
        channelDescription: 'Notifications for study reminders and progress',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleDailyReminders() async {
    final now = tz.TZDateTime.now(tz.local);
    
    // Morning reminder (7:00 AM)
    await _scheduleNotification(
      id: 1,
      title: '🌅 Good Morning! Time to Study',
      body: 'Start your day with IELTS/SAT practice. You\'ve got this!',
      scheduledTime: _nextInstanceOfTime(7, 0, now),
      payload: 'morning_reminder',
    );

    // Afternoon reminder (2:00 PM)
    await _scheduleNotification(
      id: 2,
      title: '📚 Afternoon Study Session',
      body: 'Keep up the momentum! 30 minutes of focused practice.',
      scheduledTime: _nextInstanceOfTime(14, 0, now),
      payload: 'afternoon_reminder',
    );

    // Evening reminder (8:00 PM)
    await _scheduleNotification(
      id: 3,
      title: '🌙 Evening Review',
      body: 'Review today\'s lessons and prepare for tomorrow.',
      scheduledTime: _nextInstanceOfTime(20, 0, now),
      payload: 'evening_reminder',
    );

    // Bedtime reminder (9:00 PM)
    await _scheduleNotification(
      id: 4,
      title: '😴 Rest Well',
      body: 'Good job today! Rest well for tomorrow\'s challenges.',
      scheduledTime: _nextInstanceOfTime(21, 0, now),
      payload: 'bedtime_reminder',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, tz.TZDateTime now) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    String? payload,
  }) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'ielts_sat_channel',
        'IELTS & SAT Prep',
        channelDescription: 'Notifications for study reminders and progress',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> showMilestoneNotification({
    required String milestone,
    required String achievement,
  }) async {
    await showInstantNotification(
      title: '🎉 Milestone Reached!',
      body: '$milestone: $achievement',
      payload: 'milestone',
    );
  }

  Future<void> showMotivationalNotification() async {
    final motivationalMessages = [
      'Every expert was once a beginner. Keep going!',
      'Your future self will thank you for this effort!',
      'Band 8.0 is getting closer with each study session!',
      'Success is the sum of small efforts repeated daily!',
      'You\'re investing in your future - worth every minute!',
      'One more step towards your dream score!',
      'Consistency is the key to excellence!',
      'Your hard work will pay off, keep pushing!',
    ];

    final randomMessage = motivationalMessages[
        DateTime.now().millisecondsSinceEpoch % motivationalMessages.length];

    await showInstantNotification(
      title: '💪 Keep Going!',
      body: randomMessage,
      payload: 'motivation',
    );
  }

  Future<void> showWeeklyProgressNotification({
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

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await RealNotificationService().initialize();
    await RealNotificationService().scheduleDailyReminders();
    return Future.value(true);
  });
}
