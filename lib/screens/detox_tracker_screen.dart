// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class DetoxTrackerScreen extends StatefulWidget {
  @override
  _DetoxTrackerScreenState createState() => _DetoxTrackerScreenState();
}

class _DetoxTrackerScreenState extends State<DetoxTrackerScreen> {
  bool isDetoxing = false;
  DateTime? startTime;
  Duration elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    print("Notification service initialized.");
  }

  void startDetox() {
    setState(() {
      isDetoxing = true;
      startTime = DateTime.now();
      elapsedTime = Duration.zero;
    });
    print("Detox started at: $startTime");
    _trackDetoxTime();
  }

  void stopDetox() {
    setState(() {
      isDetoxing = false;
      elapsedTime = Duration.zero;
    });
    print("Detox stopped.");
  }

  Future<void> _trackDetoxTime() async {
    print("Tracking detox time...");
    await Future.delayed(const Duration(seconds: 10));
    if (isDetoxing) {
      print("Tracking is done");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Detox Tracker')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isDetoxing
                  ? const Text(
                      'Detox in Progress...',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : const Text(
                      'Not Detoxing',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isDetoxing ? stopDetox : startDetox,
                child: Text(isDetoxing ? 'Stop Detox' : 'Start Detox'),
              ),
            ],
          ),
        ));
  }
}
