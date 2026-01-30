import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

import 'providers/ielts_provider.dart';
import 'providers/sat_provider.dart';
import 'providers/task_provider.dart';
import 'services/database_service.dart';
import 'services/gamification_service.dart';
import 'services/offline_service.dart';
import 'services/hypermax_analytics_service.dart';
import 'services/task_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database for web platform
  if (kIsWeb) {
    // For web, we'll use SharedPreferences instead of SQLite
    // Skip database initialization for web
  } else {
    // Initialize database for mobile platforms
    try {
      await DatabaseService.instance.database;
    } catch (e) {
      debugPrint('Database initialization skipped: $e');
    }
  }
  
  try {
    // Initialize other services
    await GamificationService().initialize();
    await OfflineService().initialize();
    await HypermaxAnalyticsService().initialize();
    
    // Initialize task service
    await TaskService().initialize();
    
  } catch (e) {
    debugPrint('Service initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IELTSProvider()),
        ChangeNotifierProvider(create: (_) => SATProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'IELTS & SAT Prep App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
