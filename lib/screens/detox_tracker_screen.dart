import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DetoxTrackerScreen extends StatefulWidget {
  const DetoxTrackerScreen({super.key});

  @override
  _DetoxTrackerScreenState createState() => _DetoxTrackerScreenState();
}

class _DetoxTrackerScreenState extends State<DetoxTrackerScreen>
    with WidgetsBindingObserver {
  bool isDetoxing = false;
  DateTime? startTime;
  Duration elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (isDetoxing) {
        print("Move to background or was detached");
      } else if (state == AppLifecycleState.resumed) {
        print("Resumed");
      }
    }
  }

  void startDetox() {
    setState(() {
      isDetoxing = true;
      startTime = DateTime.now();
      elapsedTime = Duration.zero;
    });
    WakelockPlus.toggle(enable: true);
    print("Detox started at: $startTime");
    _trackDetoxTime();
  }

  void stopDetox() {
    setState(() {
      isDetoxing = false;
      elapsedTime = Duration.zero;
    });
    WakelockPlus.toggle(enable: false);
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
