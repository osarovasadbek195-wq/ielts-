import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _morningReminder = true;
  bool _afternoonReminder = true;
  bool _eveningReminder = true;
  bool _weeklyReminder = true;
  Time _morningTime = const Time(7, 0);
  Time _afternoonTime = const Time(14, 0);
  Time _eveningTime = const Time(20, 0);

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get morningReminder => _morningReminder;
  bool get afternoonReminder => _afternoonReminder;
  bool get eveningReminder => _eveningReminder;
  bool get weeklyReminder => _weeklyReminder;
  Time get morningTime => _morningTime;
  Time get afternoonTime => _afternoonTime;
  Time get eveningTime => _eveningTime;

  NotificationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _morningReminder = prefs.getBool('morning_reminder') ?? true;
    _afternoonReminder = prefs.getBool('afternoon_reminder') ?? true;
    _eveningReminder = prefs.getBool('evening_reminder') ?? true;
    _weeklyReminder = prefs.getBool('weekly_reminder') ?? true;
    
    final morningHour = prefs.getInt('morning_hour') ?? 7;
    final morningMinute = prefs.getInt('morning_minute') ?? 0;
    _morningTime = Time(morningHour, morningMinute);
    
    final afternoonHour = prefs.getInt('afternoon_hour') ?? 14;
    final afternoonMinute = prefs.getInt('afternoon_minute') ?? 0;
    _afternoonTime = Time(afternoonHour, afternoonMinute);
    
    final eveningHour = prefs.getInt('evening_hour') ?? 20;
    final eveningMinute = prefs.getInt('evening_minute') ?? 0;
    _eveningTime = Time(eveningHour, eveningMinute);
    
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('morning_reminder', _morningReminder);
    await prefs.setBool('afternoon_reminder', _afternoonReminder);
    await prefs.setBool('evening_reminder', _eveningReminder);
    await prefs.setBool('weekly_reminder', _weeklyReminder);
    
    await prefs.setInt('morning_hour', _morningTime.hour);
    await prefs.setInt('morning_minute', _morningTime.minute);
    await prefs.setInt('afternoon_hour', _afternoonTime.hour);
    await prefs.setInt('afternoon_minute', _afternoonTime.minute);
    await prefs.setInt('evening_hour', _eveningTime.hour);
    await prefs.setInt('evening_minute', _eveningTime.minute);
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleMorningReminder() {
    _morningReminder = !_morningReminder;
    _saveSettings();
    notifyListeners();
  }

  void toggleAfternoonReminder() {
    _afternoonReminder = !_afternoonReminder;
    _saveSettings();
    notifyListeners();
  }

  void toggleEveningReminder() {
    _eveningReminder = !_eveningReminder;
    _saveSettings();
    notifyListeners();
  }

  void toggleWeeklyReminder() {
    _weeklyReminder = !_weeklyReminder;
    _saveSettings();
    notifyListeners();
  }

  void updateMorningTime(Time time) {
    _morningTime = time;
    _saveSettings();
    notifyListeners();
  }

  void updateAfternoonTime(Time time) {
    _afternoonTime = time;
    _saveSettings();
    notifyListeners();
  }

  void updateEveningTime(Time time) {
    _eveningTime = time;
    _saveSettings();
    notifyListeners();
  }
}

class Time {
  final int hour;
  final int minute;

  const Time(this.hour, this.minute);

  String get formatted {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
