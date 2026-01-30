import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  final List<Map<String, dynamic>> resources = const [
    {
      'title': 'IELTS Official Website',
      'url': 'https://www.ielts.org',
      'category': 'Official',
      'description': 'Official IELTS resources and practice materials',
    },
    {
      'title': 'SAT Practice',
      'url': 'https://collegereadiness.collegeboard.org/sat',
      'category': 'Official',
      'description': 'Official SAT practice tests and resources',
    },
    {
      'title': 'BBC Learning English',
      'url': 'https://www.bbc.co.uk/learningenglish',
      'category': 'English',
      'description': 'Free English learning resources',
    },
    {
      'title': 'Khan Academy',
      'url': 'https://www.khanacademy.org',
      'category': 'Math',
      'description': 'Free math lessons and practice',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(
                resource['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource['description']),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      resource['category'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.launch),
              onTap: () => _launchURL(resource['url']),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}