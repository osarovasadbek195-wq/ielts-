import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailySchedule extends StatelessWidget {
  final bool isIELTS;

  const DailySchedule({super.key, required this.isIELTS});

  @override
  Widget build(BuildContext context) {
    final schedule = isIELTS ? _getIELTSSchedule() : _getSATSchedule();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...schedule.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item['completed'] ? Colors.green : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['time'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          item['activity'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (item['completed'])
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getIELTSSchedule() {
    return [
      {
        'time': '7:00 - 9:00 AM',
        'activity': 'Morning Session: Writing Excellence',
        'completed': false,
      },
      {
        'time': '9:30 - 11:00 AM',
        'activity': 'SAT Math Practice',
        'completed': false,
      },
      {
        'time': '2:00 - 3:30 PM',
        'activity': 'Afternoon Session: Reading Comprehension',
        'completed': false,
      },
      {
        'time': '4:00 - 5:30 PM',
        'activity': 'SAT Problem Solving',
        'completed': false,
      },
      {
        'time': '8:00 - 9:00 PM',
        'activity': 'Evening Review: Vocabulary & Progress',
        'completed': false,
      },
    ];
  }

  List<Map<String, dynamic>> _getSATSchedule() {
    return [
      {
        'time': '9:30 - 11:00 AM',
        'activity': 'Math Practice: Heart of Algebra',
        'completed': false,
      },
      {
        'time': '2:00 - 3:30 PM',
        'activity': 'IELTS Listening Practice',
        'completed': false,
      },
      {
        'time': '4:00 - 5:30 PM',
        'activity': 'Problem Solving & Data Analysis',
        'completed': false,
      },
      {
        'time': '8:00 - 9:00 PM',
        'activity': 'Combined Review & Planning',
        'completed': false,
      },
    ];
  }
}
