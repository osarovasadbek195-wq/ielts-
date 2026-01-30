import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SATProvider extends ChangeNotifier {
  int _currentMathScore = 600;
  int _problemsSolved = 0;
  int _practiceTests = 0;
  int _streak = 0;
  String _lastStudyDate = '';
  double _averageTime = 87; // Average time per problem in seconds
  
  // Today's sessions
  String _morningTopic = 'Heart of Algebra';
  String _afternoonTopic = 'Problem Solving & Data Analysis';
  bool _morningCompleted = false;
  bool _afternoonCompleted = false;
  
  // Skill breakdown
  Map<String, int> _skillScores = {
    'Heart of Algebra': 150,
    'Problem Solving': 150,
    'Passport to Advanced Math': 150,
    'Additional Topics': 150,
  };

  // Getters
  int get currentMathScore => _currentMathScore;
  int get problemsSolved => _problemsSolved;
  int get practiceTests => _practiceTests;
  int get streak => _streak;
  String get lastStudyDate => _lastStudyDate;
  double get averageTime => _averageTime;
  String get morningTopic => _morningTopic;
  String get afternoonTopic => _afternoonTopic;
  bool get morningCompleted => _morningCompleted;
  bool get afternoonCompleted => _afternoonCompleted;
  Map<String, int> get skillScores => _skillScores;

  SATProvider() {
    _loadData();
    _updateDailyTopics();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentMathScore = prefs.getInt('sat_current_score') ?? 600;
    _problemsSolved = prefs.getInt('sat_problems_solved') ?? 0;
    _practiceTests = prefs.getInt('sat_practice_tests') ?? 0;
    _streak = prefs.getInt('sat_streak') ?? 0;
    _lastStudyDate = prefs.getString('sat_last_study_date') ?? '';
    _averageTime = prefs.getDouble('sat_average_time') ?? 87;
    
    // Load today's progress
    final today = DateTime.now().toString().substring(0, 10);
    if (prefs.getString('sat_today_date') == today) {
      _morningCompleted = prefs.getBool('sat_morning_completed') ?? false;
      _afternoonCompleted = prefs.getBool('sat_afternoon_completed') ?? false;
    }
    
    // Load skill scores
    _skillScores['Heart of Algebra'] = prefs.getInt('sat_heart_algebra') ?? 150;
    _skillScores['Problem Solving'] = prefs.getInt('sat_problem_solving') ?? 150;
    _skillScores['Passport to Advanced Math'] = prefs.getInt('sat_advanced_math') ?? 150;
    _skillScores['Additional Topics'] = prefs.getInt('sat_additional_topics') ?? 150;
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sat_current_score', _currentMathScore);
    await prefs.setInt('sat_problems_solved', _problemsSolved);
    await prefs.setInt('sat_practice_tests', _practiceTests);
    await prefs.setInt('sat_streak', _streak);
    await prefs.setString('sat_last_study_date', _lastStudyDate);
    await prefs.setDouble('sat_average_time', _averageTime);
    
    // Save today's progress
    final today = DateTime.now().toString().substring(0, 10);
    await prefs.setString('sat_today_date', today);
    await prefs.setBool('sat_morning_completed', _morningCompleted);
    await prefs.setBool('sat_afternoon_completed', _afternoonCompleted);
    
    // Save skill scores
    await prefs.setInt('sat_heart_algebra', _skillScores['Heart of Algebra']!);
    await prefs.setInt('sat_problem_solving', _skillScores['Problem Solving']!);
    await prefs.setInt('sat_advanced_math', _skillScores['Passport to Advanced Math']!);
    await prefs.setInt('sat_additional_topics', _skillScores['Additional Topics']!);
  }

  void _updateDailyTopics() {
    final dayOfWeek = DateTime.now().weekday;
    switch (dayOfWeek) {
      case 1: // Monday
        _morningTopic = 'Heart of Algebra';
        _afternoonTopic = 'Linear Equations';
        break;
      case 2: // Tuesday
        _morningTopic = 'Problem Solving & Data Analysis';
        _afternoonTopic = 'Ratios & Percentages';
        break;
      case 3: // Wednesday
        _morningTopic = 'Passport to Advanced Math';
        _afternoonTopic = 'Quadratic Equations';
        break;
      case 4: // Thursday
        _morningTopic = 'Additional Topics';
        _afternoonTopic = 'Geometry';
        break;
      case 5: // Friday
        _morningTopic = 'Mixed Practice';
        _afternoonTopic = 'Timed Drill';
        break;
      case 6: // Saturday
        _morningTopic = 'Full Practice Test';
        _afternoonTopic = 'Error Review';
        break;
      case 7: // Sunday
        _morningTopic = 'Weak Area Focus';
        _afternoonTopic = 'Concept Review';
        break;
    }
    notifyListeners();
  }

  Future<void> loadTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    
    if (prefs.getString('sat_today_date') != today) {
      // New day, reset progress
      _morningCompleted = false;
      _afternoonCompleted = false;
      await _saveData();
    }
  }

  void markMorningComplete() {
    _morningCompleted = true;
    _problemsSolved += 20;
    _updateStreak();
    _saveData();
    notifyListeners();
  }

  void markAfternoonComplete() {
    _afternoonCompleted = true;
    _problemsSolved += 15;
    _saveData();
    notifyListeners();
  }

  void updateMathScore(int newScore) {
    _currentMathScore = newScore;
    _saveData();
    notifyListeners();
  }

  void updateAverageTime(double newTime) {
    _averageTime = newTime;
    _saveData();
    notifyListeners();
  }

  void addProblemsSolved(int count) {
    _problemsSolved += count;
    _saveData();
    notifyListeners();
  }

  void addPracticeTest() {
    _practiceTests++;
    _saveData();
    notifyListeners();
  }

  void updateSkillScore(String skill, int score) {
    _skillScores[skill] = score;
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

  // Get motivational messages based on SAT progress
  String getMotivationalMessage() {
    if (_currentMathScore >= 750) {
      return 'Excellent! You\'re in the 750+ club!';
    } else if (_currentMathScore >= 700) {
      return 'Great job! Breaking 700 is huge!';
    } else if (_currentMathScore >= 650) {
      return 'Good progress! Keep pushing forward!';
    } else {
      return 'Every problem solved makes you stronger!';
    }
  }

  // Get progress percentage for target score
  double getProgressPercentage() {
    return ((_currentMathScore - 600) / 150) * 100;
  }

  // Get recommended focus area based on skill scores
  String getRecommendedFocus() {
    var lowestSkill = _skillScores.entries.reduce((a, b) => a.value < b.value ? a : b);
    return lowestSkill.key;
  }

  // Calculate estimated total SAT score (assuming 600 in other sections)
  int getEstimatedTotalScore() {
    return _currentMathScore + 600 + 600; // Math + Reading + Writing
  }
}
