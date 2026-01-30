import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class FunZoneScreen extends StatefulWidget {
  const FunZoneScreen({super.key});

  @override
  State<FunZoneScreen> createState() => _FunZoneScreenState();
}

class _FunZoneScreenState extends State<FunZoneScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _streak = 0;
  int _wordsCollected = 0;
  bool _isPlaying = false;

  final funActivities = [
    {
      'title': 'Quick Math Challenge',
      'description': 'Solve math problems in 60 seconds',
      'icon': Icons.timer,
      'color': Colors.purple,
      'animation': 'timer',
    },
    {
      'title': 'Word Builder',
      'description': 'Create words from letters',
      'icon': Icons.text_fields,
      'color': Colors.blue,
      'animation': 'book',
    },
    {
      'title': 'Memory Cards',
      'description': 'Test your memory with cards',
      'icon': Icons.psychology,
      'color': Colors.green,
      'animation': 'brain',
    },
    {
      'title': 'Breathing Exercise',
      'description': 'Relax with guided breathing',
      'icon': Icons.air,
      'color': Colors.teal,
      'animation': 'meditation',
    },
    {
      'title': 'Motivational Quotes',
      'description': 'Get inspired with quotes',
      'icon': Icons.format_quote,
      'color': Colors.orange,
      'animation': 'star',
    },
    {
      'title': 'Study Playlist',
      'description': 'Focus music for studying',
      'icon': Icons.music_note,
      'color': Colors.red,
      'animation': 'music',
    },
  ];

  final quotes = [
    "Success is the sum of small efforts repeated day in and day out.",
    "The expert in anything was once a beginner.",
    "Your future is created by what you do today, not tomorrow.",
    "Don't watch the clock; do what it does. Keep going.",
    "The secret of getting ahead is getting started.",
    "You don't have to be great to start, but you have to start to be great.",
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fun Zone'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: _showStats,
            icon: const Icon(Icons.leaderboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Quote Card
            Card(
              elevation: 4,
              gradient: LinearGradient(
                colors: [Colors.purple[400]!, Colors.pink[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Daily Inspiration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      quotes[Random().nextInt(quotes.length)],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Study Streak',
                    '$_streak days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Words Learned',
                    '$_wordsCollected',
                    Icons.book,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Activities Grid
            Text(
              'Quick Activities',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: funActivities.length,
              itemBuilder: (context, index) {
                final activity = funActivities[index];
                return _buildActivityCard(activity);
              },
            ),
            
            const SizedBox(height: 20),
            
            // Relaxation Section
            Text(
              'Take a Break',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/meditation.json',
                      height: 100,
                      repeat: true,
                      reverse: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '5-Minute Meditation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Clear your mind and refocus',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _startMeditation,
                      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Stop' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
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

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _startActivity(activity),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (activity['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: activity['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                activity['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                activity['description'] as String,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startActivity(Map<String, dynamic> activity) {
    final title = activity['title'] as String;
    
    switch (title) {
      case 'Quick Math Challenge':
        _showMathChallenge();
        break;
      case 'Word Builder':
        _showWordBuilder();
        break;
      case 'Memory Cards':
        _showMemoryGame();
        break;
      case 'Breathing Exercise':
        _showBreathingExercise();
        break;
      case 'Motivational Quotes':
        _showMoreQuotes();
        break;
      case 'Study Playlist':
        _showMusicPlayer();
        break;
    }
  }

  void _showMathChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Math Challenge'),
        content: const Text('Coming soon! Test your math skills against the clock.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWordBuilder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Word Builder'),
        content: const Text('Coming soon! Create words from given letters.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMemoryGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Memory Cards'),
        content: const Text('Coming soon! Match pairs of cards to test your memory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBreathingExercise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Breathing Exercise'),
        content: const Text('Coming soon! Follow the guide for relaxation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMoreQuotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('More Quotes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: quotes.map((quote) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('• $quote'),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMusicPlayer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Music'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note, size: 64, color: Colors.purple),
            const SizedBox(height: 16),
            const Text('Relaxing study music'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startMeditation() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meditation started. Focus on your breath.'),
          backgroundColor: Colors.teal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meditation paused. Take a deep breath.'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  void _showStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_fire_department, color: Colors.orange),
              title: const Text('Current Streak'),
              subtitle: Text('$_streak days'),
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('Total Words'),
              subtitle: Text('$_wordsCollected words'),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.gold),
              title: const Text('Achievements'),
              subtitle: Text('5 unlocked'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
