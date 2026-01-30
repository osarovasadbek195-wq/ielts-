import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_fonts/google_fonts.dart';

import 'providers/ielts_provider.dart';
import 'providers/sat_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/home_screen.dart';
import 'services/real_notification_service.dart';
import 'services/database_service.dart';
import 'services/gamification_service.dart';
import 'services/offline_service.dart';
import 'services/hypermax_analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  // Initialize services
  await DatabaseService.instance.database;
  await RealNotificationService().initialize();
  await GamificationService().initialize();
  await OfflineService().initialize();
  await HypermaxAnalyticsService().initialize();
  await Workmanager().initialize(callbackDispatcher);
  
  // Schedule daily notifications
  await RealNotificationService().scheduleDailyReminders();
  
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await RealNotificationService().initialize();
    await RealNotificationService().scheduleDailyReminders();
    return Future.value(true);
  });
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
