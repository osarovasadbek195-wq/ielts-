import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ielts_provider.dart';
import '../providers/sat_provider.dart';
import '../providers/task_provider.dart';
import 'resources_screen.dart';
import 'fun_zone_screen.dart';
import 'hypermax_analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Load today's progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IELTSProvider>().loadTodayProgress();
      context.read<SATProvider>().loadTodayProgress();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[600]!, Colors.purple[600]!],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IELTS & SAT Prep',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Your Path to Excellence',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '15 days',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'IELTS', icon: Icon(Icons.book)),
                        Tab(text: 'SAT', icon: Icon(Icons.calculate)),
                        Tab(text: 'Tasks', icon: Icons.task),
                        Tab(text: 'Resources', icon: Icon(Icons.library_books)),
                        Tab(text: 'Fun Zone', icon: Icon(Icons.emoji_emotions)),
                        Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                      ],
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      isScrollable: true,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIELTSTab(),
                _buildSATTab(),
                _buildTasksTab(),
                const ResourcesScreen(),
                const FunZoneScreen(),
                const HypermaxAnalyticsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIELTSTab() {
    return Consumer<IELTSProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Band Score Card
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.blue[100]!],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Band Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            provider.currentBand.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target: 8.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Progress: ${(provider.currentBand / 8.0 * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Today's Sessions
              const Text(
                'Today\'s Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Morning Session
              _buildSessionCard(
                'Morning Session',
                provider.morningTopic,
                '09:00 - 11:00',
                provider.morningCompleted,
                Icons.wb_sunny,
                Colors.orange,
                () => _toggleSession('morning', provider),
              ),
              
              const SizedBox(height: 12),
              
              // Afternoon Session
              _buildSessionCard(
                'Afternoon Session',
                provider.afternoonTopic,
                '14:00 - 16:00',
                provider.afternoonCompleted,
                Icons.wb_cloudy,
                Colors.blue,
                () => _toggleSession('afternoon', provider),
              ),
              
              const SizedBox(height: 20),
              
              // Weekly Progress
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildWeeklyChart(provider.weeklyProgress),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Words Learned', provider.wordsLearned.toString(), Icons.menu_book, Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Essays Written', provider.essaysWritten.toString(), Icons.edit, Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSATTab() {
    return Consumer<SATProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Score Card
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.purple[50]!, Colors.purple[100]!],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current SAT Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            provider.currentScore.toString(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target: 1500',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Progress: ${(provider.currentScore / 1500 * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // SAT Sections
              const Text(
                'SAT Sections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildSectionCard('Math', provider.mathScore, 800, Icons.calculate, Colors.blue),
              const SizedBox(height: 12),
              _buildSectionCard('Reading', provider.readingScore, 400, Icons.menu_book, Colors.green),
              const SizedBox(height: 12),
              _buildSectionCard('Writing', provider.writingScore, 400, Icons.edit, Colors.orange),
              
              const SizedBox(height: 20),
              
              // Practice Tests
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Practice Tests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard('Completed', provider.practiceTests.toString(), Icons.check_circle, Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard('Avg Score', provider.averageScore.toString(), Icons.trending_up, Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionCard(String title, String topic, String time, bool completed, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: completed ? color : Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: completed ? color : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: completed ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      topic,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completed ? color : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, int score, int maxScore, IconData icon, Color color) {
    final progress = score / maxScore;
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score/$maxScore',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(Map<String, double> progress) {
    return Column(
      children: progress.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.value.toInt()}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _toggleSession(String session, dynamic provider) {
    // Toggle session completion
    switch (session) {
      case 'morning':
        provider.toggleMorningSession();
        break;
      case 'afternoon':
        provider.toggleAfternoonSession();
        break;
    }
  }

  Widget _buildTasksTab() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Tasks', provider.taskStats['total'].toString(), Icons.task, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Completed', provider.taskStats['completed'].toString(), Icons.check_circle, Colors.green),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Today', provider.taskStats['today'].toString(), Icons.today, Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Overdue', provider.taskStats['overdue'].toString(), Icons.warning, Colors.red),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.addQuickTask('ielts', 'study_session'),
                      icon: const Icon(Icons.add),
                      label: const Text('IELTS Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.addQuickTask('sat', 'practice_test'),
                      icon: const Icon(Icons.add),
                      label: const Text('SAT Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.addDailyTasks(),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Daily Tasks'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.addWeeklyTasks(),
                      icon: const Icon(Icons.date_range),
                      label: const Text('Weekly Goals'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Today's Tasks
              if (provider.todayTasks.isNotEmpty) ...[
                const Text(
                  'Today\'s Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.todayTasks.map((task) => _buildTaskCard(task, provider)),
                const SizedBox(height: 20),
              ],
              
              // High Priority Tasks
              if (provider.highPriorityTasks.isNotEmpty) ...[
                const Text(
                  'High Priority',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.highPriorityTasks.take(3).map((task) => _buildTaskCard(task, provider)),
                const SizedBox(height: 20),
              ],
              
              // Upcoming Tasks
              if (provider.upcomingTasks.isNotEmpty) ...[
                const Text(
                  'Upcoming (7 days)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.upcomingTasks.take(3).map((task) => _buildTaskCard(task, provider)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, TaskProvider provider) {
    final isOverdue = provider.isOverdue(task.deadline);
    final isApproaching = provider.isDeadlineApproaching(task.deadline);
    
    Color priorityColor;
    switch (task.priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue ? Colors.red : isApproaching ? Colors.orange : Colors.grey[300]!,
            width: isOverdue || isApproaching ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Priority indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: isOverdue ? Colors.red : isApproaching ? Colors.orange : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.formatDeadline(task.deadline),
                        style: TextStyle(
                          color: isOverdue ? Colors.red : isApproaching ? Colors.orange : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: isOverdue || isApproaching ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          task.priority.toUpperCase(),
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!task.isCompleted)
                  IconButton(
                    onPressed: () => provider.completeTask(task),
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                  ),
                if (task.isCompleted)
                  IconButton(
                    onPressed: () => provider.uncompleteTask(task),
                    icon: const Icon(Icons.check_circle),
                    color: Colors.green,
                  ),
                IconButton(
                  onPressed: () => provider.deleteTask(task),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
