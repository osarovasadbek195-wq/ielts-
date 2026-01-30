import 'package:flutter/foundation.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  List<Task> get tasks => _taskService.tasks;
  List<Task> get completedTasks => _taskService.completedTasks;
  List<Task> get allTasks => _taskService.allTasks;
  
  // Category-specific tasks
  List<Task> get ieltsTasks => _taskService.ieltsTasks;
  List<Task> get satTasks => _taskService.satTasks;
  List<Task> get generalTasks => _taskService.generalTasks;
  
  // Priority-specific tasks
  List<Task> get highPriorityTasks => _taskService.highPriorityTasks;
  List<Task> get mediumPriorityTasks => _taskService.mediumPriorityTasks;
  List<Task> get lowPriorityTasks => _taskService.lowPriorityTasks;
  
  // Time-specific tasks
  List<Task> get todayTasks => _taskService.todayTasks;
  List<Task> get overdueTasks => _taskService.overdueTasks;
  List<Task> get upcomingTasks => _taskService.upcomingTasks;
  
  // Statistics
  Map<String, int> get taskStats => _taskService.getTaskStats();
  double get completionRate => _taskService.getCompletionRate();
  double get productivityScore => _taskService.getProductivityScore();

  TaskProvider() {
    _taskService.addListener(_onTaskServiceChanged);
  }

  void _onTaskServiceChanged() {
    notifyListeners();
  }

  // Task management methods
  Future<void> addTask({
    required String title,
    required String description,
    required DateTime deadline,
    required String priority,
    required String category,
  }) async {
    await _taskService.addTask(
      title: title,
      description: description,
      deadline: deadline,
      priority: priority,
      category: category,
    );
  }

  Future<void> updateTask(
    Task task, {
    String? title,
    String? description,
    DateTime? deadline,
    String? priority,
    String? category,
  }) async {
    await _taskService.updateTask(
      task,
      title: title,
      description: description,
      deadline: deadline,
      priority: priority,
      category: category,
    );
  }

  Future<void> completeTask(Task task) async {
    await _taskService.completeTask(task);
  }

  Future<void> uncompleteTask(Task task) async {
    await _taskService.uncompleteTask(task);
  }

  Future<void> deleteTask(Task task) async {
    await _taskService.deleteTask(task);
  }

  Future<void> clearCompletedTasks() async {
    await _taskService.clearCompletedTasks();
  }

  // Utility methods
  String formatDeadline(DateTime deadline) {
    return _taskService.formatDeadline(deadline);
  }

  bool isDeadlineApproaching(DateTime deadline) {
    return _taskService.isDeadlineApproaching(deadline);
  }

  bool isOverdue(DateTime deadline) {
    return _taskService.isOverdue(deadline);
  }

  // Quick task templates
  Future<void> addQuickTask(String category, String type) async {
    final now = DateTime.now();
    String title;
    String description;
    DateTime deadline;
    String priority;

    switch (type) {
      case 'study_session':
        title = 'Study Session';
        description = 'Complete a focused study session';
        deadline = now.add(const Duration(hours: 2));
        priority = 'medium';
        break;
      case 'practice_test':
        title = 'Practice Test';
        description = 'Take a full practice test';
        deadline = now.add(const Duration(days: 1));
        priority = 'high';
        break;
      case 'review_session':
        title = 'Review Session';
        description = 'Review previous mistakes and concepts';
        deadline = now.add(const Duration(hours: 3));
        priority = 'low';
        break;
      case 'vocabulary':
        title = 'Vocabulary Practice';
        description = 'Learn and practice new vocabulary';
        deadline = now.add(const Duration(hours: 1));
        priority = 'low';
        break;
      default:
        title = 'Quick Task';
        description = 'Complete this task';
        deadline = now.add(const Duration(hours: 2));
        priority = 'medium';
    }

    await addTask(
      title: '$title - $category',
      description: description,
      deadline: deadline,
      priority: priority,
      category: category,
    );
  }

  // Batch operations
  Future<void> addDailyTasks() async {
    final now = DateTime.now();
    
    // Morning study session
    await addTask(
      title: 'Morning Study Session',
      description: 'Start your day with focused study',
      deadline: DateTime(now.year, now.month, now.day, 10, 0),
      priority: 'high',
      category: 'general',
    );

    // Afternoon practice
    await addTask(
      title: 'Afternoon Practice',
      description: 'Practice what you learned in the morning',
      deadline: DateTime(now.year, now.month, now.day, 15, 0),
      priority: 'medium',
      category: 'general',
    );

    // Evening review
    await addTask(
      title: 'Evening Review',
      description: 'Review today\'s learning and mistakes',
      deadline: DateTime(now.year, now.month, now.day, 20, 0),
      priority: 'medium',
      category: 'general',
    );
  }

  Future<void> addWeeklyTasks() async {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    // Weekly goals
    await addTask(
      title: 'Complete 3 Practice Tests',
      description: 'Take and review 3 full practice tests this week',
      deadline: weekFromNow,
      priority: 'high',
      category: 'general',
    );

    await addTask(
      title: 'Review All Mistakes',
      description: 'Go through all mistakes from practice tests',
      deadline: weekFromNow,
      priority: 'medium',
      category: 'general',
    );

    await addTask(
      title: 'Update Study Plan',
      description: 'Review and update your study plan based on progress',
      deadline: weekFromNow,
      priority: 'low',
      category: 'general',
    );
  }

  // Study streak management
  Future<void> updateStudyStreak() async {
    final todayCompleted = completedTasks.where((task) => 
      task.completedAt != null && 
      task.completedAt!.day == DateTime.now().day
    ).length;

    if (todayCompleted > 0) {
      // Calculate streak (simplified - in real app, you'd track this in SharedPreferences)
      final streakDays = await _calculateStreakDays();
      
      // Streak tracking without notifications
      debugPrint('Study streak: $streakDays days');
    }
  }

  Future<int> _calculateStreakDays() async {
    // Simplified streak calculation
    // In a real implementation, you'd track this in SharedPreferences
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dayCompleted = completedTasks.any((task) => 
        task.completedAt != null && 
        task.completedAt!.year == checkDate.year &&
        task.completedAt!.month == checkDate.month &&
        task.completedAt!.day == checkDate.day
      );
      
      if (dayCompleted) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    
    return streak;
  }

  @override
  void dispose() {
    _taskService.removeListener(_onTaskServiceChanged);
    super.dispose();
  }
}
