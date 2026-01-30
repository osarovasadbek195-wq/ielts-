import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hypermax_analytics_service.dart';
import '../widgets/simple_progress_chart.dart';

class HypermaxAnalyticsScreen extends StatefulWidget {
  const HypermaxAnalyticsScreen({super.key});

  @override
  State<HypermaxAnalyticsScreen> createState() => _HypermaxAnalyticsScreenState();
}

class _HypermaxAnalyticsScreenState extends State<HypermaxAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final HypermaxAnalyticsService _analytics = HypermaxAnalyticsService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hypermax Analytics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Insights', icon: Icon(Icons.insights)),
            Tab(text: 'Energy', icon: Icon(Icons.bolt)),
            Tab(text: 'Focus', icon: Icon(Icons.center_focus_strong)),
            Tab(text: 'Strategy', icon: Icon(Icons.lightbulb)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInsightsTab(),
          _buildEnergyTab(),
          _buildFocusTab(),
          _buildStrategyTab(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    final insights = _analytics.generateHypermaxInsights();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Performance Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Overall Performance',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceMetrics(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Energy Optimization
          _buildInsightCard(
            'Energy Optimization',
            insights['energyOptimization'],
            Icons.bolt,
            Colors.orange,
          ),
          
          const SizedBox(height: 16),
          
          // Focus Optimization
          _buildInsightCard(
            'Focus Optimization',
            insights['focusOptimization'],
            Icons.center_focus_strong,
            Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // Learning Efficiency
          _buildInsightCard(
            'Learning Efficiency',
            insights['learningEfficiency'],
            Icons.school,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      children: [
        _buildMetricRow('Study Efficiency', '87%', Colors.green),
        _buildMetricRow('Energy Utilization', '78%', Colors.orange),
        _buildMetricRow('Focus Consistency', '82%', Colors.blue),
        _buildMetricRow('Skill Progression', '91%', Colors.purple),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, Map<String, dynamic> data, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.entries.map((entry) => _buildInsightItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              _formatKey(key),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatValue(value),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key.split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value['description'] ?? value.toString();
    }
    return value.toString();
  }

  Widget _buildEnergyTab() {
    final energyLevels = _analytics.energyLevels;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Energy Overview
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Energy Levels',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...energyLevels.entries.map((entry) => 
                    _buildEnergyBar(entry.key, entry.value)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Energy Management Tips
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Energy Management Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    'Peak Performance',
                    'Schedule challenging tasks during your high-energy periods (usually morning)',
                    Icons.schedule,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildTipCard(
                    'Energy Recovery',
                    'Take strategic breaks every 45-60 minutes to maintain energy levels',
                    Icons.coffee,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildTipCard(
                    'Energy Conservation',
                    'Match task difficulty with your current energy level',
                    Icons.battery_charging_full,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyBar(String principle, double level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                principle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '${level.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getEnergyColor(level),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: level / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getEnergyColor(level),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEnergyColor(double level) {
    if (level >= 80) return Colors.green;
    if (level >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTipCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTab() {
    final focusScores = _analytics.focusScores;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Focus Overview
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Scores',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...focusScores.entries.map((entry) => 
                    _buildFocusBar(entry.key, entry.value)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Focus Optimization
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Focus Optimization',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptimizationItem(
                    'Environment Design',
                    'Minimize distractions in your study space',
                    Icons.room_preferences,
                    Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildOptimizationItem(
                    'Time Blocking',
                    'Dedicate specific time blocks for focused work',
                    Icons.schedule,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildOptimizationItem(
                    'Digital Detox',
                    'Limit phone usage during study sessions',
                    Icons.phone_android,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusBar(String principle, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                principle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '${score.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getFocusColor(score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getFocusColor(score),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFocusColor(double score) {
    if (score >= 85) return Colors.blue;
    if (score >= 70) return Colors.green;
    if (score >= 55) return Colors.orange;
    return Colors.red;
  }

  Widget _buildOptimizationItem(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyTab() {
    final recommendations = _analytics.generatePersonalizedRecommendations();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strategy Overview
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hypermax Strategy Recommendations',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Based on your performance patterns, here are personalized strategies to optimize your learning:',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recommendations List
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildRecommendationCard(
                index + 1,
                recommendation['principle'],
                recommendation['recommendation'],
                recommendation['expectedImpact'],
                recommendation['priority'],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(int number, String principle, String recommendation, String impact, String priority) {
    final priorityColor = _getPriorityColor(priority);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    principle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  impact,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
