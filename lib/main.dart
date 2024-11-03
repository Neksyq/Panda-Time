import 'package:flutter/material.dart';
import 'package:pandatime/screens/statistics/statistics_screen.dart';
import 'screens/bamboo_break/bamboo_break_tracker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/growth_stats': (context) => const GrowStats(),
        },
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: BambooBreakTrackerScreen(),
        ));
  }
}
