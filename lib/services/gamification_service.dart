import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final String category;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'category': category,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      points: json['points'],
      category: json['category'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
    );
  }
}

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final List<Achievement> _achievements = [];
  int _totalPoints = 0;
  int _currentLevel = 1;
  int _studyStreak = 0;
  DateTime? _lastStudyDate;

  // Getters
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  int get totalPoints => _totalPoints;
  int get currentLevel => _currentLevel;
  int get studyStreak => _studyStreak;
  DateTime? get lastStudyDate => _lastStudyDate;

  // Initialize achievements
  Future<void> initialize() async {
    await _loadData();
    _setupDefaultAchievements();
  }

  void _setupDefaultAchievements() {
    if (_achievements.isEmpty) {
      _achievements.addAll([
        // Study Streak Achievements
        Achievement(
          id: 'first_day',
          title: 'First Steps',
          description: 'Complete your first study session',
          icon: '🌟',
          points: 10,
          category: 'Study Streak',
        ),
        Achievement(
          id: 'week_warrior',
          title: 'Week Warrior',
          description: 'Study for 7 consecutive days',
          icon: '🔥',
          points: 50,
          category: 'Study Streak',
        ),
        Achievement(
          id: 'month_master',
          title: 'Month Master',
          description: 'Study for 30 consecutive days',
          icon: '👑',
          points: 200,
          category: 'Study Streak',
        ),

        // IELTS Achievements
        Achievement(
          id: 'ielts_band_6',
          title: 'IELTS Band 6.0',
          description: 'Reach Band 6.0 in any IELTS skill',
          icon: '📊',
          points: 30,
          category: 'IELTS',
        ),
        Achievement(
          id: 'ielts_band_7',
          title: 'IELTS Band 7.0',
          description: 'Reach Band 7.0 in any IELTS skill',
          icon: '📈',
          points: 100,
          category: 'IELTS',
        ),
        Achievement(
          id: 'ielts_band_8',
          title: 'IELTS Band 8.0',
          description: 'Reach Band 8.0 in any IELTS skill',
          icon: '🏆',
          points: 300,
          category: 'IELTS',
        ),

        // SAT Achievements
        Achievement(
          id: 'sat_1200',
          title: 'SAT 1200+',
          description: 'Score 1200+ in practice test',
          icon: '🎯',
          points: 50,
          category: 'SAT',
        ),
        Achievement(
          id: 'sat_1400',
          title: 'SAT 1400+',
          description: 'Score 1400+ in practice test',
          icon: '🚀',
          points: 150,
          category: 'SAT',
        ),
        Achievement(
          id: 'sat_1500',
          title: 'SAT 1500+',
          description: 'Score 1500+ in practice test',
          icon: '🌟',
          points: 500,
          category: 'SAT',
        ),

        // Vocabulary Achievements
        Achievement(
          id: 'vocab_100',
          title: 'Word Collector',
          description: 'Learn 100 new words',
          icon: '📚',
          points: 25,
          category: 'Vocabulary',
        ),
        Achievement(
          id: 'vocab_500',
          title: 'Vocabulary Master',
          description: 'Learn 500 new words',
          icon: '📖',
          points: 100,
          category: 'Vocabulary',
        ),
        Achievement(
          id: 'vocab_1000',
          title: 'Word Wizard',
          description: 'Learn 1000 new words',
          icon: '🔮',
          points: 250,
          category: 'Vocabulary',
        ),

        // Special Achievements
        Achievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Complete 5 morning study sessions',
          icon: '🌅',
          points: 30,
          category: 'Special',
        ),
        Achievement(
          id: 'night_owl',
          title: 'Night Owl',
          description: 'Complete 5 evening study sessions',
          icon: '🦉',
          points: 30,
          category: 'Special',
        ),
        Achievement(
          id: 'perfect_week',
          title: 'Perfect Week',
          description: 'Complete all scheduled sessions for a week',
          icon: '💯',
          points: 100,
          category: 'Special',
        ),
      ]);
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load total points
    _totalPoints = prefs.getInt('total_points') ?? 0;
    _currentLevel = _calculateLevel(_totalPoints);
    
    // Load study streak
    _studyStreak = prefs.getInt('study_streak') ?? 0;
    final lastStudyDateStr = prefs.getString('last_study_date');
    if (lastStudyDateStr != null) {
      _lastStudyDate = DateTime.parse(lastStudyDateStr);
    }
    
    // Load achievements
    final achievementsJson = prefs.getStringList('achievements') ?? [];
    _achievements.clear();
    for (final json in achievementsJson) {
      // Parse achievement from JSON (simplified)
      // In real implementation, use proper JSON parsing
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('total_points', _totalPoints);
    await prefs.setInt('study_streak', _studyStreak);
    if (_lastStudyDate != null) {
      await prefs.setString('last_study_date', _lastStudyDate!.toIso8601String());
    }
    
    // Save achievements
    final achievementsJson = _achievements.map((a) => a.toString()).toList();
    await prefs.setStringList('achievements', achievementsJson);
  }

  int _calculateLevel(int points) {
    // Level calculation: every 100 points = 1 level
    return (points ~/ 100) + 1;
  }

  Future<void> addStudySession() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastStudyDate != null) {
      final lastStudyDay = DateTime(
        _lastStudyDate!.year, 
        _lastStudyDate!.month, 
        _lastStudyDate!.day
      );
      
      final difference = today.difference(lastStudyDay).inDays;
      
      if (difference == 1) {
        _studyStreak++;
      } else if (difference > 1) {
        _studyStreak = 1;
      }
    } else {
      _studyStreak = 1;
    }
    
    _lastStudyDate = now;
    
    // Add points for study session
    await addPoints(5);
    
    // Check streak achievements
    await _checkStreakAchievements();
    
    await _saveData();
  }

  Future<void> addPoints(int points) async {
    _totalPoints += points;
    _currentLevel = _calculateLevel(_totalPoints);
    await _saveData();
  }

  Future<void> unlockAchievement(String achievementId) async {
    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );
    
    if (!achievement.isUnlocked) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      
      await addPoints(achievement.points);
      await _saveData();
    }
  }

  Future<void> _checkStreakAchievements() async {
    if (_studyStreak >= 1) {
      await unlockAchievement('first_day');
    }
    if (_studyStreak >= 7) {
      await unlockAchievement('week_warrior');
    }
    if (_studyStreak >= 30) {
      await unlockAchievement('month_master');
    }
  }

  Future<void> checkIELTSAchievement(double bandScore) async {
    if (bandScore >= 6.0) {
      await unlockAchievement('ielts_band_6');
    }
    if (bandScore >= 7.0) {
      await unlockAchievement('ielts_band_7');
    }
    if (bandScore >= 8.0) {
      await unlockAchievement('ielts_band_8');
    }
  }

  Future<void> checkSATAchievement(int score) async {
    if (score >= 1200) {
      await unlockAchievement('sat_1200');
    }
    if (score >= 1400) {
      await unlockAchievement('sat_1400');
    }
    if (score >= 1500) {
      await unlockAchievement('sat_1500');
    }
  }

  Future<void> checkVocabularyAchievement(int wordCount) async {
    if (wordCount >= 100) {
      await unlockAchievement('vocab_100');
    }
    if (wordCount >= 500) {
      await unlockAchievement('vocab_500');
    }
    if (wordCount >= 1000) {
      await unlockAchievement('vocab_1000');
    }
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  int getPointsToNextLevel() {
    final nextLevelPoints = _currentLevel * 100;
    return nextLevelPoints - _totalPoints;
  }

  double getLevelProgress() {
    final currentLevelPoints = (_currentLevel - 1) * 100;
    final nextLevelPoints = _currentLevel * 100;
    final pointsInCurrentLevel = _totalPoints - currentLevelPoints;
    final pointsNeededForLevel = nextLevelPoints - currentLevelPoints;
    
    return pointsInCurrentLevel / pointsNeededForLevel;
  }

  String getLevelTitle() {
    final titles = [
      'Beginner', 'Novice', 'Learner', 'Student', 'Scholar',
      'Expert', 'Master', 'Scholar', 'Genius', 'Legend'
    ];
    
    final index = (_currentLevel - 1).clamp(0, titles.length - 1);
    return titles[index];
  }

  // Generate random motivational quote
  String getRandomMotivationalQuote() {
    final quotes = [
      "Every expert was once a beginner!",
      "Your progress is amazing, keep going!",
      "Success is the sum of small efforts!",
      "You're closer to your goal than yesterday!",
      "Consistency is the key to excellence!",
      "Your dedication will pay off!",
      "One more step towards your dream!",
      "You're building your future today!",
    ];
    
    return quotes[Random().nextInt(quotes.length)];
  }
}
