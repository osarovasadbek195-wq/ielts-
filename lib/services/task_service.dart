import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String priority; // 'high', 'medium', 'low'
  final String category; // 'ielts', 'sat', 'general'
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      priority: json['priority'],
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    String? priority,
    String? category,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class TaskService extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _completedTasks = [];
  
  List<Task> get tasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _completedTasks;
  List<Task> get allTasks => [..._tasks, ..._completedTasks];
  
  // Get tasks by category
  List<Task> get ieltsTasks => _tasks.where((task) => task.category == 'ielts' && !task.isCompleted).toList();
  List<Task> get satTasks => _tasks.where((task) => task.category == 'sat' && !task.isCompleted).toList();
  List<Task> get generalTasks => _tasks.where((task) => task.category == 'general' && !task.isCompleted).toList();
  
  // Get tasks by priority
  List<Task> get highPriorityTasks => _tasks.where((task) => task.priority == 'high' && !task.isCompleted).toList();
  List<Task> get mediumPriorityTasks => _tasks.where((task) => task.priority == 'medium' && !task.isCompleted).toList();
  List<Task> get lowPriorityTasks => _tasks.where((task) => task.priority == 'low' && !task.isCompleted).toList();
  
  // Get today's tasks
  List<Task> get todayTasks {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return _tasks.where((task) => 
      !task.isCompleted && 
      task.deadline.isAfter(todayStart) && 
      task.deadline.isBefore(todayEnd)
    ).toList();
  }
  
  // Get overdue tasks
  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) => 
      !task.isCompleted && task.deadline.isBefore(now)
    ).toList();
  }
  
  // Get upcoming tasks (next 7 days)
  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return _tasks.where((task) => 
      !task.isCompleted && 
      task.deadline.isAfter(now) && 
      task.deadline.isBefore(nextWeek)
    ).toList();
  }

  TaskService() {
    _loadTasks();
  }

  Future<void> initialize() async {
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList('tasks') ?? [];
      
      _tasks = tasksJson
          .map((jsonString) => Task.fromJson(jsonDecode(jsonString)))
          .toList();
      
      // Separate completed tasks
      _completedTasks = _tasks.where((task) => task.isCompleted).toList();
      _tasks = _tasks.where((task) => !task.isCompleted).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allTasks = [..._tasks, ..._completedTasks];
      final tasksJson = allTasks.map((task) => jsonEncode(task.toJson())).toList();
      
      await prefs.setStringList('tasks', tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime deadline,
    required String priority,
    required String category,
  }) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      deadline: deadline,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
    );

    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task task, {
    String? title,
    String? description,
    DateTime? deadline,
    String? priority,
    String? category,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(
        title: title,
        description: description,
        deadline: deadline,
        priority: priority,
        category: category,
      );
      
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> completeTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final completedTask = _tasks[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      
      _tasks.removeAt(index);
      _completedTasks.add(completedTask);
      
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> uncompleteTask(Task task) async {
    final index = _completedTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final uncompletedTask = _completedTasks[index].copyWith(
        isCompleted: false,
        completedAt: null,
      );
      
      _completedTasks.removeAt(index);
      _tasks.add(uncompletedTask);
      
      // Sort tasks by deadline
      _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((t) => t.id == task.id);
    _completedTasks.removeWhere((t) => t.id == task.id);
    
    await _saveTasks();
    notifyListeners();
  }

  Future<void> clearCompletedTasks() async {
    _completedTasks.clear();
    await _saveTasks();
    notifyListeners();
  }

  // Task statistics
  Map<String, int> getTaskStats() {
    return {
      'total': allTasks.length,
      'pending': tasks.length,
      'completed': completedTasks.length,
      'today': todayTasks.length,
      'overdue': overdueTasks.length,
      'high_priority': highPriorityTasks.length,
    };
  }

  // Get task completion rate
  double getCompletionRate() {
    final total = allTasks.length;
    if (total == 0) return 0.0;
    return (completedTasks.length / total) * 100;
  }

  // Get productivity score (0-100)
  double getProductivityScore() {
    double score = 0.0;
    
    // Base score from completion rate
    score += getCompletionRate() * 0.4;
    
    // Bonus for completing high priority tasks
    final highPriorityCompleted = _completedTasks.where((task) => task.priority == 'high').length;
    score += (highPriorityCompleted * 10).clamp(0.0, 20.0);
    
    // Penalty for overdue tasks
    score -= (overdueTasks.length * 5).clamp(0.0, 20.0);
    
    // Bonus for completing tasks on time
    final onTimeCompleted = _completedTasks.where((task) => 
      task.completedAt != null && task.completedAt!.isBefore(task.deadline)
    ).length;
    score += (onTimeCompleted * 5).clamp(0.0, 20.0);
    
    return score.clamp(0.0, 100.0);
  }

  // Format deadline for display
  String formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 1 && difference.inDays <= 7) {
      return '${difference.inDays} days';
    } else {
      return DateFormat('MMM dd, yyyy').format(deadline);
    }
  }

  // Check if deadline is approaching (within 24 hours)
  bool isDeadlineApproaching(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inHours <= 24 && difference.inHours > 0;
  }

  // Check if deadline is overdue
  bool isOverdue(DateTime deadline) {
    return deadline.isBefore(DateTime.now());
  }
}
