import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class HypermaxAnalyticsService {
  static final HypermaxAnalyticsService _instance = HypermaxAnalyticsService._internal();
  factory HypermaxAnalyticsService() => _instance;
  HypermaxAnalyticsService._internal();

  // Hypermax Method Components
  Map<String, double> _energyLevels = {};
  Map<String, double> _focusScores = {};
  Map<String, int> _sessionDurations = {};
  Map<String, List<String>> _peakPerformanceTimes = {};
  Map<String, Map<String, double>> _skillProgressionRates = {};
  
  // Advanced Metrics
  Map<String, double> _cognitiveLoadScores = {};
  Map<String, double> _retentionRates = {};
  Map<String, List<int>> _optimalStudyIntervals = {};
  Map<String, Map<String, dynamic>> _learningPatterns = {};
  Map<String, double> _efficiencyScores = {};

  // Hypermax Principles
  static const List<String> HYPERMAX_PRINCIPLES = [
    'Energy Management',
    'Focus Optimization', 
    'Strategic Timing',
    'Progressive Overload',
    'Recovery Integration',
    'Habit Stacking',
    'Environmental Design',
    'Feedback Loops'
  ];

  static const Map<String, List<String>> SKILL_BREAKDOWN = {
    'IELTS': ['Listening', 'Reading', 'Writing', 'Speaking', 'Grammar', 'Vocabulary'],
    'SAT': ['Math', 'Reading', 'Writing', 'Problem Solving', 'Time Management', 'Strategy']
  };

  Future<void> initialize() async {
    await _loadAnalyticsData();
    await _initializeHypermaxMetrics();
  }

  Future<void> _initializeHypermaxMetrics() async {
    // Initialize energy tracking
    for (final principle in HYPERMAX_PRINCIPLES) {
      _energyLevels[principle] = 75.0; // Default 75% energy
      _focusScores[principle] = 80.0;  // Default 80% focus
      _sessionDurations[principle] = 0;
      _peakPerformanceTimes[principle] = [];
      _efficiencyScores[principle] = 0.0;
    }

    // Initialize skill progression tracking
    for (final exam in SKILL_BREAKDOWN.keys) {
      _skillProgressionRates[exam] = {};
      _cognitiveLoadScores[exam] = 0.0;
      _retentionRates[exam] = 0.0;
      _optimalStudyIntervals[exam] = [25, 50]; // Pomodoro intervals
      _learningPatterns[exam] = {};
      
      for (final skill in SKILL_BREAKDOWN[exam]!) {
        _skillProgressionRates[exam]![skill] = 0.0;
        _learningPatterns[exam]![skill] = {
          'bestTime': '',
          'optimalDuration': 45,
          'difficultyProgression': 1.0,
          'masteryLevel': 0.0,
          'retentionDecay': 0.1,
        };
      }
    }
  }

  // Determine which Hypermax principle applies to this session
  String _determineHypermaxPrinciple(String skill, double energy, double focus) {
    if (energy >= 80 && focus >= 85) return 'Energy Management';
    if (focus >= 80) return 'Focus Optimization';
    if (skill.contains('Writing') || skill.contains('Math')) return 'Progressive Overload';
    if (energy < 60) return 'Recovery Integration';
    return 'Strategic Timing';
  }

  // Record study session with Hypermax metrics
  Future<void> recordHypermaxSession({
    required String examType,
    required String skill,
    required DateTime startTime,
    required DateTime endTime,
    required double energyLevel,
    required double focusScore,
    required int problemsSolved,
    required double accuracy,
    required List<String> distractions,
    required String environment,
  }) async {
    final duration = endTime.difference(startTime).inMinutes;
    final principle = _determineHypermaxPrinciple(skill, energyLevel, focusScore);
    
    // Update energy and focus tracking
    _energyLevels[principle] = (_energyLevels[principle]! * 0.7) + (energyLevel * 0.3);
    _focusScores[principle] = (_focusScores[principle]! * 0.7) + (focusScore * 0.3);
    _sessionDurations[principle] = (_sessionDurations[principle]! + duration);
    
    // Calculate cognitive load
    final cognitiveLoad = _calculateCognitiveLoad(
      duration, 
      problemsSolved, 
      distractions.length,
      accuracy
    );
    _cognitiveLoadScores[examType] = cognitiveLoad;
    
    // Update learning patterns
    await _updateLearningPatterns(
      examType, 
      skill, 
      startTime, 
      duration, 
      accuracy,
      cognitiveLoad
    );
    
    // Calculate efficiency score
    final efficiency = _calculateEfficiencyScore(
      duration, 
      problemsSolved, 
      accuracy, 
      energyLevel,
      focusScore
    );
    _efficiencyScores[principle] = efficiency;
    
    // Track peak performance times
    await _trackPeakPerformance(principle, startTime, efficiency);
    
    // Update retention rates
    await _updateRetentionRates(examType, skill, accuracy);
    
    // Save data
    await _saveAnalyticsData();
  }

  double _calculateCognitiveLoad(int duration, int problems, int distractions, double accuracy) {
    final problemDensity = problems / max(duration, 1);
    final distractionPenalty = distractions * 0.1;
    final accuracyBonus = (1.0 - accuracy) * 0.2;
    
    return (problemDensity + distractionPenalty + accuracyBonus).clamp(0.0, 1.0);
  }

  double _calculateEfficiencyScore(
    int duration, 
    int problems, 
    double accuracy, 
    double energy,
    double focus
  ) {
    final timeEfficiency = problems / max(duration, 1);
    final qualityFactor = accuracy;
    final energyFactor = energy / 100.0;
    final focusFactor = focus / 100.0;
    
    return (timeEfficiency * qualityFactor * energyFactor * focusFactor * 100).clamp(0.0, 100.0);
  }

  Future<void> _updateLearningPatterns(
    String examType,
    String skill,
    DateTime startTime,
    int duration,
    double accuracy,
    double cognitiveLoad
  ) async {
    final pattern = _learningPatterns[examType]![skill]!;
    
    // Update best study time
    final hour = startTime.hour;
    if (accuracy > (pattern['masteryLevel'] as double)) {
      pattern['bestTime'] = '$hour:00';
    }
    
    // Update optimal duration
    final currentOptimal = pattern['optimalDuration'] as int;
    if (cognitiveLoad < 0.7 && accuracy > 0.8) {
      pattern['optimalDuration'] = duration;
    }
    
    // Update mastery level
    final currentMastery = pattern['masteryLevel'] as double;
    pattern['masteryLevel'] = (currentMastery * 0.8) + (accuracy * 0.2);
    
    // Update difficulty progression
    final currentDifficulty = pattern['difficultyProgression'] as double;
    if (accuracy > 0.85) {
      pattern['difficultyProgression'] = min(currentDifficulty + 0.1, 3.0);
    } else if (accuracy < 0.6) {
      pattern['difficultyProgression'] = max(currentDifficulty - 0.05, 0.5);
    }
  }

  Future<void> _trackPeakPerformance(String principle, DateTime time, double efficiency) async {
    if (efficiency > 85) {
      final timeString = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      _peakPerformanceTimes[principle]!.add(timeString);
      
      // Keep only top 5 peak times
      _peakPerformanceTimes[principle]!.sort((a, b) => a.compareTo(b));
      if (_peakPerformanceTimes[principle]!.length > 5) {
        _peakPerformanceTimes[principle]!.removeRange(5, _peakPerformanceTimes[principle]!.length);
      }
    }
  }

  Future<void> _updateRetentionRates(String examType, String skill, double accuracy) async {
    final currentRate = _retentionRates[examType] ?? 0.0;
    _retentionRates[examType] = (currentRate * 0.9) + (accuracy * 0.1);
  }

  // Generate Hypermax insights
  Map<String, dynamic> generateHypermaxInsights() {
    final insights = <String, dynamic>{};
    
    // Energy Management Insights
    insights['energyOptimization'] = {
      'bestEnergyTime': _findBestEnergyTime(),
      'energyTrend': 'Increasing', // Simplified
      'recoveryRecommendations': _generateRecoveryRecommendations(),
    };
    
    // Focus Optimization Insights
    insights['focusOptimization'] = {
      'peakFocusHours': _findPeakFocusHours(),
      'focusDuration': _calculateOptimalFocusDuration(),
      'distractionPatterns': ['Phone notifications', 'Social media'], // Simplified
    };
    
    // Learning Efficiency Insights
    insights['learningEfficiency'] = {
      'mostEfficientSkills': ['IELTS Writing', 'SAT Math'], // Simplified
      'optimalStudyIntervals': _getOptimalIntervals(),
      'masteryProgression': 'Steady improvement', // Simplified
    };
    
    // Hypermax Strategy Recommendations
    insights['strategyRecommendations'] = _generateHypermaxStrategies();
    
    return insights;
  }

  String _findBestEnergyTime() {
    if (_energyLevels.isEmpty) return '09:00 - 11:00';
    
    final bestEntry = _energyLevels.entries.reduce((a, b) => 
        a.value > b.value ? a : b);
    return bestEntry.key;
  }

  List<String> _generateRecoveryRecommendations() {
    final recommendations = <String>[];
    
    for (final principle in HYPERMAX_PRINCIPLES) {
      final energy = _energyLevels[principle]!;
      final focus = _focusScores[principle]!;
      
      if (energy < 60) {
        recommendations.add('Increase rest periods for $principle');
      }
      if (focus < 70) {
        recommendations.add('Optimize environment for $principle');
      }
      if (_sessionDurations[principle]! > 120) {
        recommendations.add('Break down $principle sessions into smaller chunks');
      }
    }
    
    return recommendations;
  }

  List<int> _findPeakFocusHours() {
    final peakHours = <int>[];
    
    for (final times in _peakPerformanceTimes.values) {
      for (final time in times) {
        final hour = int.parse(time.split(':')[0]);
        if (!peakHours.contains(hour)) {
          peakHours.add(hour);
        }
      }
    }
    
    peakHours.sort();
    return peakHours;
  }

  int _calculateOptimalFocusDuration() {
    int totalDuration = 0;
    int sessionCount = 0;
    
    for (final principle in HYPERMAX_PRINCIPLES) {
      if (_sessionDurations[principle]! > 0) {
        totalDuration += _sessionDurations[principle]!;
        sessionCount++;
      }
    }
    
    return sessionCount > 0 ? (totalDuration / sessionCount).round() : 45;
  }

  List<int> _getOptimalIntervals() {
    return [25, 50]; // Pomodoro technique
  }

  Map<String, dynamic> _generateHypermaxStrategies() {
    return {
      'energyBasedScheduling': {
        'description': 'Schedule high-energy tasks during peak performance times',
        'implementation': _findBestEnergyTime(),
        'expectedImprovement': '+25% efficiency',
      },
      'focusBlockOptimization': {
        'description': 'Use optimal focus duration based on your patterns',
        'implementation': '${_calculateOptimalFocusDuration()} minute blocks',
        'expectedImprovement': '+30% retention',
      },
      'progressiveDifficulty': {
        'description': 'Gradually increase difficulty based on mastery levels',
        'implementation': 'Adaptive difficulty system',
        'expectedImprovement': '+40% skill progression',
      },
      'recoveryIntegration': {
        'description': 'Strategic recovery periods between intense sessions',
        'implementation': 'Micro-breaks every 25 minutes',
        'expectedImprovement': '+20% sustainability',
      },
    };
  }

  // Personalized recommendations
  List<Map<String, dynamic>> generatePersonalizedRecommendations() {
    final recommendations = <Map<String, dynamic>>[];
    
    // Analyze each principle
    for (final principle in HYPERMAX_PRINCIPLES) {
      final energy = _energyLevels[principle]!;
      final focus = _focusScores[principle]!;
      final efficiency = _efficiencyScores[principle]!;
      
      if (efficiency < 70) {
        recommendations.add({
          'principle': principle,
          'type': 'optimization',
          'priority': 'high',
          'recommendation': _generateOptimizationRecommendation(principle, energy, focus),
          'expectedImpact': '+${(90 - efficiency).round()}% efficiency',
        });
      }
    }
    
    // Skill-specific recommendations
    for (final exam in SKILL_BREAKDOWN.keys) {
      for (final skill in SKILL_BREAKDOWN[exam]!) {
        final pattern = _learningPatterns[exam]![skill]!;
        final mastery = pattern['masteryLevel'] as double;
        
        if (mastery < 0.6) {
          recommendations.add({
            'principle': 'Skill Mastery',
            'type': 'skill_improvement',
            'priority': 'medium',
            'recommendation': 'Focus on $skill during ${pattern['bestTime']}',
            'expectedImpact': '+${((0.8 - mastery) * 100).round()}% mastery',
          });
        }
      }
    }
    
    // Sort by priority and impact
    recommendations.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      final aPriority = priorityOrder[a['priority']] ?? 0;
      final bPriority = priorityOrder[b['priority']] ?? 0;
      return bPriority.compareTo(aPriority);
    });
    
    return recommendations.take(10).toList();
  }

  String _generateOptimizationRecommendation(String principle, double energy, double focus) {
    if (energy < 60 && focus < 70) {
      return 'Take a break and recharge before $principle sessions';
    } else if (energy < 60) {
      return 'Schedule $principle during high-energy periods';
    } else if (focus < 70) {
      return 'Minimize distractions during $principle work';
    } else {
      return 'Optimize session duration for $principle';
    }
  }

  // Data persistence
  Future<void> _saveAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save energy levels
    for (final principle in HYPERMAX_PRINCIPLES) {
      await prefs.setDouble('energy_$principle', _energyLevels[principle]!);
      await prefs.setDouble('focus_$principle', _focusScores[principle]!);
      await prefs.setInt('duration_$principle', _sessionDurations[principle]!);
      await prefs.setDouble('efficiency_$principle', _efficiencyScores[principle]!);
    }
    
    // Save learning patterns (simplified)
    for (final exam in SKILL_BREAKDOWN.keys) {
      await prefs.setDouble('retention_$exam', _retentionRates[exam] ?? 0.0);
      await prefs.setDouble('cognitive_$exam', _cognitiveLoadScores[exam] ?? 0.0);
    }
  }

  Future<void> _loadAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load energy levels
    for (final principle in HYPERMAX_PRINCIPLES) {
      _energyLevels[principle] = prefs.getDouble('energy_$principle') ?? 75.0;
      _focusScores[principle] = prefs.getDouble('focus_$principle') ?? 80.0;
      _sessionDurations[principle] = prefs.getInt('duration_$principle') ?? 0;
      _efficiencyScores[principle] = prefs.getDouble('efficiency_$principle') ?? 0.0;
    }
    
    // Load learning patterns
    for (final exam in SKILL_BREAKDOWN.keys) {
      _retentionRates[exam] = prefs.getDouble('retention_$exam') ?? 0.0;
      _cognitiveLoadScores[exam] = prefs.getDouble('cognitive_$exam') ?? 0.0;
    }
  }

  // Getters for UI
  Map<String, double> get energyLevels => Map.unmodifiable(_energyLevels);
  Map<String, double> get focusScores => Map.unmodifiable(_focusScores);
  Map<String, double> get efficiencyScores => Map.unmodifiable(_efficiencyScores);
  Map<String, Map<String, dynamic>> get learningPatterns => Map.unmodifiable(_learningPatterns);
}
