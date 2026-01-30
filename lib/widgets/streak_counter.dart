import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ielts_provider.dart';
import '../providers/sat_provider.dart';

class StreakCounter extends StatelessWidget {
  const StreakCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<IELTSProvider, SATProvider>(
      builder: (context, ieltsProvider, satProvider, child) {
        final combinedStreak = ieltsProvider.streak + satProvider.streak;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '$combinedStreak Day Streak!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
