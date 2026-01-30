import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IELTSProvider extends ChangeNotifier {
  double _currentBand = 5.5;
  int _wordsLearned = 0;
  int _essaysWritten = 0;
  int _practiceTests = 0;
  int _streak = 0;
  String _lastStudyDate = '';
  
  // Today's sessions
  String _morningTopic = 'Writing Task 2';
  String _afternoonTopic = 'Reading Comprehension';
  bool _morningCompleted = false;
  bool _afternoonCompleted = false;
  bool _eveningCompleted = false;
  
  // Weekly progress
  Map<String, double> _weeklyProgress = {
    'Mon': 0.0,
    'Tue': 0.0,
    'Wed': 0.0,
    'Thu': 0.0,
    'Fri': 0.0,
    'Sat': 0.0,
    'Sun': 0.0,
  };

  // Getters
  double get currentBand => _currentBand;
  int get wordsLearned => _wordsLearned;
  int get essaysWritten => _essaysWritten;
  int get practiceTests => _practiceTests;
  int get streak => _streak;
  String get lastStudyDate => _lastStudyDate;
  String get morningTopic => _morningTopic;
  String get afternoonTopic => _afternoonTopic;
  bool get morningCompleted => _morningCompleted;
  bool get afternoonCompleted => _afternoonCompleted;
  bool get eveningCompleted => _eveningCompleted;
  Map<String, double> get weeklyProgress => _weeklyProgress;

  IELTSProvider() {
    _loadData();
    _updateDailyTopics();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentBand = prefs.getDouble('ielts_current_band') ?? 5.5;
      _wordsLearned = prefs.getInt('ielts_words_learned') ?? 0;
      _essaysWritten = prefs.getInt('ielts_essays_written') ?? 0;
      _practiceTests = prefs.getInt('ielts_practice_tests') ?? 0;
      _streak = prefs.getInt('ielts_streak') ?? 0;
      _lastStudyDate = prefs.getString('ielts_last_study_date') ?? '';
      
      // Load today's progress
      final today = DateTime.now().toString().substring(0, 10);
      if (prefs.getString('ielts_today_date') == today) {
        _morningCompleted = prefs.getBool('ielts_morning_completed') ?? false;
        _afternoonCompleted = prefs.getBool('ielts_afternoon_completed') ?? false;
        _eveningCompleted = prefs.getBool('ielts_evening_completed') ?? false;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading IELTS data: $e');
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ielts_current_band', _currentBand);
    await prefs.setInt('ielts_words_learned', _wordsLearned);
    await prefs.setInt('ielts_essays_written', _essaysWritten);
    await prefs.setInt('ielts_practice_tests', _practiceTests);
    await prefs.setInt('ielts_streak', _streak);
    await prefs.setString('ielts_last_study_date', _lastStudyDate);
    
    // Save today's progress
    final today = DateTime.now().toString().substring(0, 10);
    await prefs.setString('ielts_today_date', today);
    await prefs.setBool('ielts_morning_completed', _morningCompleted);
    await prefs.setBool('ielts_afternoon_completed', _afternoonCompleted);
    await prefs.setBool('ielts_evening_completed', _eveningCompleted);
  }

  void _updateDailyTopics() {
    final dayOfWeek = DateTime.now().weekday;
    switch (dayOfWeek) {
      case 1: // Monday
        _morningTopic = 'Writing Task 2';
        _afternoonTopic = 'Reading Comprehension';
        break;
      case 2: // Tuesday
        _morningTopic = 'Reading Speed';
        _afternoonTopic = 'Listening Section 1-2';
        break;
      case 3: // Wednesday
        _morningTopic = 'Listening Sections 3-4';
        _afternoonTopic = 'Speaking Part 1-2';
        break;
      case 4: // Thursday
        _morningTopic = 'Speaking Part 3';
        _afternoonTopic = 'Writing Task 1';
        break;
      case 5: // Friday
        _morningTopic = 'Full Practice Test';
        _afternoonTopic = 'Error Analysis';
        break;
      case 6: // Saturday
        _morningTopic = 'Mock Test Review';
        _afternoonTopic = 'Weak Area Focus';
        break;
      case 7: // Sunday
        _morningTopic = 'Weekly Review';
        _afternoonTopic = 'Planning Next Week';
        break;
    }
    notifyListeners();
  }

  Future<void> loadTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    
    if (prefs.getString('ielts_today_date') != today) {
      // New day, reset progress
      _morningCompleted = false;
      _afternoonCompleted = false;
      _eveningCompleted = false;
      await _saveData();
    }
  }

  void markMorningComplete() {
    _morningCompleted = true;
    _updateStreak();
    _saveData();
    notifyListeners();
  }

  void markAfternoonComplete() {
    _afternoonCompleted = true;
    _saveData();
    notifyListeners();
  }

  void markEveningComplete() {
    _eveningCompleted = true;
    _wordsLearned += 20; // Add 20 words for evening review
    _saveData();
    notifyListeners();
  }

  void toggleMorningSession() {
    _morningCompleted = !_morningCompleted;
    if (_morningCompleted) {
      _wordsLearned += 30;
      _updateStreak();
    }
    _saveData();
    notifyListeners();
  }

  void toggleAfternoonSession() {
    _afternoonCompleted = !_afternoonCompleted;
    if (_afternoonCompleted) {
      _wordsLearned += 25;
      _updateStreak();
    }
    _saveData();
    notifyListeners();
  }

  void updateBandScore(double newScore) {
    _currentBand = newScore;
    _saveData();
    notifyListeners();
  }

  void addWordsLearned(int count) {
    _wordsLearned += count;
    _saveData();
    notifyListeners();
  }

  void addEssayWritten() {
    _essaysWritten++;
    _saveData();
    notifyListeners();
  }

  void addPracticeTest() {
    _practiceTests++;
    _saveData();
    notifyListeners();
  }

  void _updateStreak() {
    final today = DateTime.now().toString().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toString().substring(0, 10);
    
    if (_lastStudyDate == yesterday) {
      _streak++;
    } else if (_lastStudyDate != today) {
      _streak = 1;
    }
    
    _lastStudyDate = today;
  }

  void updateWeeklyProgress(String day, double hours) {
    _weeklyProgress[day] = hours;
    notifyListeners();
  }

  // Get motivational messages based on progress
  String getMotivationalMessage() {
    if (_streak >= 30) {
      return 'Amazing! 30-day streak! You\'re unstoppable!';
    } else if (_streak >= 14) {
      return 'Two weeks strong! Consistency is key!';
    } else if (_streak >= 7) {
      return 'One week complete! Keep the momentum!';
    } else if (_streak >= 3) {
      return 'Great start! Three days in a row!';
    } else {
      return 'Every journey begins with a single step!';
    }
  }

  // Get progress percentage for each skill
  double getReadingProgress() => ((_currentBand - 5.5) / 2.5) * 100;
  double getWritingProgress() => ((_currentBand - 5.5) / 2.5) * 100;
  double getListeningProgress() => ((_currentBand - 5.5) / 2.5) * 100;
  double getSpeakingProgress() => ((_currentBand - 5.5) / 2.5) * 100;
}
