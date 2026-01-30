import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ielts_provider.dart';
import '../providers/sat_provider.dart';
import '../widgets/study_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/streak_counter.dart';
import '../widgets/daily_schedule.dart';
import '../widgets/simple_progress_chart.dart';
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
    _tabController = TabController(length: 5, vsync: this);
    
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.blue[600],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('IELTS & SAT Prep', style: TextStyle(color: Colors.white)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[600]!, Colors.purple[600]!],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreakCounter(),
                        SizedBox(height: 10),
                        Text(
                          'Your Path to Excellence',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'IELTS', icon: Icon(Icons.book)),
                  Tab(text: 'SAT', icon: Icon(Icons.calculate)),
                  Tab(text: 'Resources', icon: Icon(Icons.library_books)),
                  Tab(text: 'Fun Zone', icon: Icon(Icons.emoji_emotions)),
                  Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                isScrollable: true,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildIELTSTab(),
            _buildSATTab(),
            const ResourcesScreen(),
            const FunZoneScreen(),
            const HypermaxAnalyticsScreen(),
          ],
        ),
        ),
    );
  }

  void _showAnalytics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Advanced Analytics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SimpleProgressChart(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIELTSTab() {
    return Consumer<IELTSProvider>(
      builder: (context, ieltsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Overview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Band: ${ieltsProvider.currentBand}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Target: Band 8.0'),
                      const SizedBox(height: 16),
                      const ProgressChart(isIELTS: true),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Today's Schedule
              Text(
                "Today's Schedule",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const DailySchedule(isIELTS: true),
              
              const SizedBox(height: 20),
              
              // Study Cards
              Text(
                'Study Sessions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              StudyCard(
                title: 'Morning Session',
                time: '7:00 - 9:00 AM',
                topic: ieltsProvider.morningTopic,
                completed: ieltsProvider.morningCompleted,
                onTap: () => _markComplete(context, 'morning', true),
              ),
              const SizedBox(height: 10),
              StudyCard(
                title: 'Afternoon Session',
                time: '2:00 - 3:30 PM',
                topic: ieltsProvider.afternoonTopic,
                completed: ieltsProvider.afternoonCompleted,
                onTap: () => _markComplete(context, 'afternoon', true),
              ),
              const SizedBox(height: 10),
              StudyCard(
                title: 'Evening Review',
                time: '8:00 - 9:00 PM',
                topic: 'Vocabulary & Progress',
                completed: ieltsProvider.eveningCompleted,
                onTap: () => _markComplete(context, 'evening', true),
              ),
              
              const SizedBox(height: 20),
              
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.book, size: 32, color: Colors.blue[600]),
                            const SizedBox(height: 8),
                            Text('${ieltsProvider.wordsLearned}'),
                            const Text('Words Learned'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.edit, size: 32, color: Colors.green[600]),
                            const SizedBox(height: 8),
                            Text('${ieltsProvider.essaysWritten}'),
                            const Text('Essays Written'),
                          ],
                        ),
                      ),
                    ),
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
      builder: (context, satProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Overview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Math Score: ${satProvider.currentMathScore}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Target: 750+'),
                      const SizedBox(height: 16),
                      const ProgressChart(isIELTS: false),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Today's Schedule
              Text(
                "Today's Schedule",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const DailySchedule(isIELTS: false),
              
              const SizedBox(height: 20),
              
              // Study Cards
              Text(
                'Study Sessions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              StudyCard(
                title: 'Math Practice',
                time: '9:30 - 11:00 AM',
                topic: satProvider.morningTopic,
                completed: satProvider.morningCompleted,
                onTap: () => _markComplete(context, 'morning', false),
              ),
              const SizedBox(height: 10),
              StudyCard(
                title: 'Problem Solving',
                time: '4:00 - 5:30 PM',
                topic: satProvider.afternoonTopic,
                completed: satProvider.afternoonCompleted,
                onTap: () => _markComplete(context, 'afternoon', false),
              ),
              
              const SizedBox(height: 20),
              
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.quiz, size: 32, color: Colors.purple[600]),
                            const SizedBox(height: 8),
                            Text('${satProvider.problemsSolved}'),
                            const Text('Problems Solved'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.timer, size: 32, color: Colors.orange[600]),
                            const SizedBox(height: 8),
                            Text('${satProvider.averageTime}s'),
                            const Text('Avg. per Problem'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _markComplete(BuildContext context, String session, bool isIELTS) {
    if (isIELTS) {
      final provider = context.read<IELTSProvider>();
      switch (session) {
        case 'morning':
          provider.markMorningComplete();
          break;
        case 'afternoon':
          provider.markAfternoonComplete();
          break;
        case 'evening':
          provider.markEveningComplete();
          break;
      }
    } else {
      final provider = context.read<SATProvider>();
      switch (session) {
        case 'morning':
          provider.markMorningComplete();
          break;
        case 'afternoon':
          provider.markAfternoonComplete();
          break;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great job! Session marked complete.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
