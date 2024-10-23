import 'package:flutter/material.dart';
import 'screens/detox_tracker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detox Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DetoxTrackerScreen(),
    );
  }
}
