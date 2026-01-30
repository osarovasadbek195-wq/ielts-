import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ielts_provider.dart';
import '../providers/sat_provider.dart';

class SimpleProgressChart extends StatelessWidget {
  const SimpleProgressChart({super.key});

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
            _buildProgressBars(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars(BuildContext context) {
    final ieltsProvider = context.watch<IELTSProvider>();
    final satProvider = context.watch<SATProvider>();

    return Column(
      children: [
        // IELTS Progress
        _buildProgressBar(
          context,
          'IELTS Overall',
          ieltsProvider.currentBand / 8.0, // Normalize to 0-1
          Colors.blue,
        ),
        const SizedBox(height: 12),
        
        // SAT Progress
        _buildProgressBar(
          context,
          'SAT Math',
          satProvider.currentMathScore / 800.0, // Normalize to 0-1
          Colors.purple,
        ),
        const SizedBox(height: 12),
        
        // Study Streak
        _buildProgressBar(
          context,
          'Study Streak',
          0.7, // Fixed value for now
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String title,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
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
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final int points;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.amber : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '$points',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.amber : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'pts',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OfflineStatusIndicator extends StatelessWidget {
  const OfflineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Offline Mode Active',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Sync Pending',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
