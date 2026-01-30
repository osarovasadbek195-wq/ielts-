import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification channels
  static const String _studyReminderChannel = 'study_reminders';
  static const String _taskDeadlineChannel = 'task_deadlines';
  static const String _motivationChannel = 'motivation';
  static const String _achievementChannel = 'achievements';

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      
      // Initialize notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

      // Create notification channels
      await _createNotificationChannels();

      _initialized = true;
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    const androidChannels = [
      AndroidNotificationChannel(
        _studyReminderChannel,
        'Study Reminders',
        description: 'Reminders for study sessions and practice',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
      AndroidNotificationChannel(
        _taskDeadlineChannel,
        'Task Deadlines',
        description: 'Alerts for upcoming task deadlines',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
      AndroidNotificationChannel(
        _motivationChannel,
        'Daily Motivation',
        description: 'Motivational quotes and tips',
        importance: Importance.defaultImportance,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
      AndroidNotificationChannel(
        _achievementChannel,
        'Achievements',
        description: 'Celebrations for milestones and achievements',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
    ];

    for (final channel in androidChannels) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap (e.g., navigate to specific screen)
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    final result = await androidPlugin?.requestNotificationsPermission();
    return result ?? false;
  }

  // Study session reminders
  Future<void> scheduleStudyReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      await _notifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _studyReminderChannel,
            'Study Reminders',
            channelDescription: 'Reminders for study sessions',
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling study reminder: $e');
    }
  }

  // Task deadline notifications
  Future<void> scheduleTaskDeadlineReminder({
    required String taskTitle,
    required DateTime deadline,
    required String priority,
  }) async {
    try {
      final now = DateTime.now();
      final reminderTime = deadline.subtract(const Duration(hours: 2));
      
      if (reminderTime.isAfter(now)) {
        await _notifications.zonedSchedule(
          deadline.millisecondsSinceEpoch.remainder(100000),
          'Task Deadline Approaching',
          '$taskTitle is due in 2 hours! Priority: $priority',
          tz.TZDateTime.from(reminderTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _taskDeadlineChannel,
              'Task Deadlines',
              channelDescription: 'Alerts for upcoming task deadlines',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: const Color(0xFFFF6B6B),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'task_deadline',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling task deadline reminder: $e');
    }
  }

  // Daily motivation notifications
  Future<void> scheduleDailyMotivation() async {
    try {
      final now = DateTime.now();
      final today9AM = DateTime(now.year, now.month, now.day, 9, 0, 0);
      final scheduledTime = today9AM.isAfter(now) ? today9AM : today9AM.add(const Duration(days: 1));

      await _notifications.zonedSchedule(
        999,
        'Daily Motivation',
        _getMotivationalQuote(),
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _motivationChannel,
            'Daily Motivation',
            channelDescription: 'Motivational quotes and tips',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF4CAF50),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'daily_motivation',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling daily motivation: $e');
    }
  }

  // Achievement notifications
  Future<void> showAchievementNotification({
    required String title,
    required String description,
  }) async {
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '🎉 $title',
        description,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _achievementChannel,
            'Achievements',
            channelDescription: 'Celebrations for milestones and achievements',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFFFD700),
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'achievement',
      );
    } catch (e) {
      debugPrint('Error showing achievement notification: $e');
    }
  }

  // Study streak notifications
  Future<void> showStreakNotification(int streakDays) async {
    try {
      String message;
      if (streakDays == 1) {
        message = 'Great start! Keep the momentum going!';
      } else if (streakDays == 7) {
        message = 'Amazing! One week streak! You\'re unstoppable!';
      } else if (streakDays == 30) {
        message = 'Incredible! 30-day streak! You\'re a champion!';
      } else {
        message = 'Fantastic! $streakDays days of consistent learning!';
      }

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '🔥 Study Streak: $streakDays Days',
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _achievementChannel,
            'Achievements',
            channelDescription: 'Celebrations for milestones and achievements',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFFF6B6B),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'streak_achievement',
      );
    } catch (e) {
      debugPrint('Error showing streak notification: $e');
    }
  }

  // Progress milestone notifications
  Future<void> showProgressNotification({
    required String examType,
    required double currentScore,
    required double targetScore,
    required String milestone,
  }) async {
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        '📈 $examType Progress Milestone',
        'Congratulations! You\'ve reached $milestone: $currentScore/$targetScore',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _achievementChannel,
            'Achievements',
            channelDescription: 'Celebrations for milestones and achievements',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF2196F3),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'progress_milestone',
      );
    } catch (e) {
      debugPrint('Error showing progress notification: $e');
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  // Get motivational quotes
  String _getMotivationalQuote() {
    final quotes = [
      "Success is the sum of small efforts repeated day in and day out.",
      "The expert in anything was once a beginner.",
      "Don't watch the clock; do what it does. Keep going.",
      "Your limitation—it's only your imagination.",
      "Great things never come from comfort zones.",
      "Dream it. Wish it. Do it.",
      "Success doesn't just find you. You have to go out and get it.",
      "The harder you work for something, the greater you'll feel when you achieve it.",
      "Dream bigger. Do bigger.",
      "Don't stop when you're tired. Stop when you're done.",
      "Wake up with determination. Go to bed with satisfaction.",
      "Do something today that your future self will thank you for.",
      "Little things make big days.",
      "It's going to be hard, but hard does not mean impossible.",
      "Don't wait for opportunity. Create it.",
      "Sometimes we're tested not to show our weaknesses, but to discover our strengths.",
      "The key to success is to focus on goals, not obstacles.",
      "Dream it. Believe it. Build it.",
      "The only way to do great work is to love what you do.",
      "Believe you can and you're halfway there.",
    ];

    return quotes[DateTime.now().day % quotes.length];
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      final result = await androidPlugin?.areNotificationsEnabled();
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  // Save notification preferences
  Future<void> saveNotificationPreferences({
    bool? studyReminders,
    bool? taskDeadlines,
    bool? dailyMotivation,
    bool? achievements,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (studyReminders != null) {
        await prefs.setBool('notif_study_reminders', studyReminders);
      }
      if (taskDeadlines != null) {
        await prefs.setBool('notif_task_deadlines', taskDeadlines);
      }
      if (dailyMotivation != null) {
        await prefs.setBool('notif_daily_motivation', dailyMotivation);
      }
      if (achievements != null) {
        await prefs.setBool('notif_achievements', achievements);
      }
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
    }
  }

  // Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'study_reminders': prefs.getBool('notif_study_reminders') ?? true,
        'task_deadlines': prefs.getBool('notif_task_deadlines') ?? true,
        'daily_motivation': prefs.getBool('notif_daily_motivation') ?? true,
        'achievements': prefs.getBool('notif_achievements') ?? true,
      };
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
      return {
        'study_reminders': true,
        'task_deadlines': true,
        'daily_motivation': true,
        'achievements': true,
      };
    }
  }
}
