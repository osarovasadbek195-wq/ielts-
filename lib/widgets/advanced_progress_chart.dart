import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/ielts_provider.dart';
import '../providers/sat_provider.dart';

class AdvancedProgressChart extends StatelessWidget {
  const AdvancedProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(context),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: _buildBarChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final ieltsProvider = context.watch<IELTSProvider>();
    final satProvider = context.watch<SATProvider>();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: 7,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // IELTS Progress Line
          LineChartBarData(
            spots: _generateProgressSpots(ieltsProvider.skillScores),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          // SAT Progress Line
          LineChartBarData(
            spots: _generateProgressSpots(satProvider.skillScores),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final ieltsProvider = context.watch<IELTSProvider>();
    final satProvider = context.watch<SATProvider>();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'IELTS';
                    break;
                  case 1:
                    text = 'SAT';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          // IELTS Overall Progress
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: ieltsProvider.overallProgress,
                color: Colors.blue,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
          // SAT Overall Progress
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: satProvider.overallProgress,
                color: Colors.purple,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateProgressSpots(Map<String, double> skillScores) {
    // Generate sample progress data over 7 days
    final spots = <FlSpot>[];
    final baseValue = skillScores.values.isNotEmpty 
        ? skillScores.values.reduce((a, b) => a + b) / skillScores.length 
        : 50.0;
    
    for (int i = 0; i <= 7; i++) {
      final progress = baseValue + (i * 3) + (i % 2 == 0 ? 2 : -1);
      spots.add(FlSpot(i.toDouble(), progress.clamp(0.0, 100.0)));
    }
    
    return spots;
  }
}

class SkillRadarChart extends StatelessWidget {
  final Map<String, double> skillScores;
  final String title;
  final Color primaryColor;

  const SkillRadarChart({
    super.key,
    required this.skillScores,
    required this.title,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildRadarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    return RadarChart(
      RadarChartData(
        radarTouchData: RadarTouchData(
          touchCallback: (FlTouchEvent event, response) {
            // Handle touch events
          },
        ),
        data: [
          RadarDataSet(
            fillColor: primaryColor.withOpacity(0.3),
            borderColor: primaryColor,
            pointBackgroundColor: primaryColor,
            pointBorderColor: Colors.white,
            pointRadius: 4,
            dataEntries: skillScores.entries
                .map((entry) => RadarEntry(value: entry.value))
                .toList(),
          ),
        ],
        radarBorderData: const BorderSide(color: Colors.transparent),
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
        tickBorderData: const BorderSide(color: Colors.transparent),
        gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
        titleTextStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        titlePositionPercentageOffset: 0.2,
        titles: skillScores.keys.map((skill) {
          return RadarChartTitle(text: skill);
        }).toList(),
      ),
    );
  }
}
