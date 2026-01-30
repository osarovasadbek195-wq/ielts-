import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/ielts_provider.dart';
import 'providers/sat_provider.dart';
import 'providers/task_provider.dart';
import 'services/database_service.dart';
import 'services/gamification_service.dart';
import 'services/offline_service.dart';
import 'services/hypermax_analytics_service.dart';
import 'services/task_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize core services
    await DatabaseService.instance.database;
    await GamificationService().initialize();
    await OfflineService().initialize();
    await HypermaxAnalyticsService().initialize();
    
    // Initialize task and notification services
    await TaskService().initialize();
    await NotificationService().initialize();
    
    // Request notification permissions
    await NotificationService().requestPermissions();
    
    // Schedule daily motivation
    await NotificationService().scheduleDailyMotivation();
    
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
