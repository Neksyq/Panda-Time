// ignore_for_file: library_private_types_in_public_api

import 'package:pandatime/components/custom/processIndicator/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DetoxTrackerScreen extends StatefulWidget {
  const DetoxTrackerScreen({super.key});

  @override
  _DetoxTrackerScreenState createState() => _DetoxTrackerScreenState();
}

class _DetoxTrackerScreenState extends State<DetoxTrackerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int maxDuration = 5; // Default max duration in seconds
  bool isDetoxing = false;
  DateTime? startTime;
  Duration elapsedTime = Duration.zero;

  // List of selectable times for the detox session (in minutes)
  final List<int> detoxTimes =
      List.generate(24 * 60 ~/ 5, (index) => (index + 1) * 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();
    WakelockPlus.enable();
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: maxDuration))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isDetoxing = false;
        }
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    WakelockPlus.disable();
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
      _controller.reset();
      _controller.forward();
      isDetoxing = true;
      startTime = DateTime.now();
      elapsedTime = Duration.zero;
    });
    WakelockPlus.toggle(enable: true);
    _trackDetoxTime();
  }

  void stopDetox() {
    setState(() {
      isDetoxing = false;
      _controller.reset();
      elapsedTime = Duration.zero;
    });
    WakelockPlus.toggle(enable: false);
  }

  Future<void> _trackDetoxTime() async {
    await Future.delayed(const Duration(seconds: 10));
    if (isDetoxing) {
      print("Tracking is done");
    }
  }

  void _showTimePicker(BuildContext context) {
    int selectedIndex = detoxTimes.indexOf(maxDuration ~/ 60); // Initial index

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Detox Duration (Minutes)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        // Set the selected value and close the picker
                        setState(() {
                          maxDuration = detoxTimes[selectedIndex] * 60;
                          _controller.duration = Duration(seconds: maxDuration);
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(fontSize: 18, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  onSelectedItemChanged: (index) {
                    // Update the selected index
                    selectedIndex = index;
                  },
                  children: detoxTimes.map((time) {
                    return Center(
                      child: Text(
                        '$time minutes',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String intToTimeLeft(int value) {
    int h, m, s;

    h = value ~/ 3600;

    m = ((value - h * 3600)) ~/ 60;

    s = value - (h * 3600) - (m * 60);

    String hourLeft =
        h.toString().length < 2 ? "0" + h.toString() : h.toString();

    String minuteLeft =
        m.toString().length < 2 ? "0" + m.toString() : m.toString();

    String secondsLeft =
        s.toString().length < 2 ? "0" + s.toString() : s.toString();

    String result = "$hourLeft:$minuteLeft:$secondsLeft";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = const [
      Color(0xffFF0069),
      Color(0xffFED602),
      Color(0xff7639FB),
      Color(0xffD500C5),
      Color(0xffFF7A01),
      Color(0xffFF0069),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Panda Time')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                isDetoxing
                    ? const Text(
                        'Detox in Progress...',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : const Text(
                        'Not Detoxing',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
              ],
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/panda.jpg', // Update with the path to your image
                          fit: BoxFit.cover,
                        ),
                      ),
                      CustomPaint(
                        painter: RadialProgressPainter(
                          value: _controller.value * maxDuration,
                          backgroundGradientColors: gradientColors,
                          minValue: 0,
                          maxValue: maxDuration.toDouble(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  intToTimeLeft(maxDuration),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showTimePicker(context);
              },
              child: const Text('Set Detox Duration'),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isDetoxing ? stopDetox : startDetox,
              child: Text(isDetoxing ? 'Stop Detox' : 'Start Detox'),
            ),
          ],
        ),
      ),
    );
  }
}
