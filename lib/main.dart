import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandatime/screens/authentication/authentication_screen.dart';
import 'package:pandatime/screens/statistics/statistics_screen.dart';
import 'screens/bamboo_break/bamboo_break_tracker_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white,
        ),
        routes: {
          '/growth_stats': (context) => const GrowStats(),
          '/panda_home': (context) => const BambooBreakTrackerScreen()
        },
        debugShowCheckedModeBanner: false,
        home: const BambooBreakTrackerScreen());
  }
}
