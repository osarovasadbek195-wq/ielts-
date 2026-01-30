import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/ielts_provider.dart';
import 'providers/sat_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/gamification_service.dart';
import 'services/offline_service.dart';
import 'services/hypermax_analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  try {
    await DatabaseService.instance.database;
    await GamificationService().initialize();
    await OfflineService().initialize();
    await HypermaxAnalyticsService().initialize();
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
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
