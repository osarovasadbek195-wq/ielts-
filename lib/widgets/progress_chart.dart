import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:charts_flutter/flutter.dart' as charts;  // Temporarily commented
import '../providers/ielts_provider.dart';
import '../providers/sat_provider.dart';

class ProgressChart extends StatelessWidget {
  final bool isIELTS;

  const ProgressChart({super.key, required this.isIELTS});

  @override
  Widget build(BuildContext context) {
    if (isIELTS) {
      return Consumer<IELTSProvider>(
        builder: (context, provider, child) {
          final data = [
            {'skill': 'Reading', 'percentage': provider.getReadingProgress(), 'color': Colors.blue},
            {'skill': 'Writing', 'percentage': provider.getWritingProgress(), 'color': Colors.green},
            {'skill': 'Listening', 'percentage': provider.getListeningProgress(), 'color': Colors.orange},
            {'skill': 'Speaking', 'percentage': provider.getSpeakingProgress(), 'color': Colors.purple},
          ];

          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: data.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          item['skill'] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (item['percentage'] as double) / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 35,
                        child: Text(
                          '${(item['percentage'] as double).toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    } else {
      return Consumer<SATProvider>(
        builder: (context, provider, child) {
          final data = provider.skillScores.entries.map((entry) {
            return {
              'skill': entry.key.length > 15 ? entry.key.substring(0, 12) + '...' : entry.key,
              'percentage': (entry.value / 200) * 100,
              'color': Colors.blue,
            };
          }).toList();

          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: data.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          item['skill'] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (item['percentage'] as double) / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 35,
                        child: Text(
                          '${(item['percentage'] as double).toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }
}

// Temporarily commented out class
/*
class ProgressData {
  final String skill;
  final double percentage;
  final charts.Color color;

  ProgressData(this.skill, this.percentage, Color color)
      : color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
*/
