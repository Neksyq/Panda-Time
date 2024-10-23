import 'package:detoxtime/components/custom/processIndicator/liquid_painter.dart';
import 'package:detoxtime/components/custom/processIndicator/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DetoxTrackerScreen extends StatefulWidget {
  const DetoxTrackerScreen({super.key});

  @override
  _DetoxTrackerScreenState createState() => _DetoxTrackerScreenState();
}

class _DetoxTrackerScreenState extends State<DetoxTrackerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int maxDuration = 10;
  bool isDetoxing = false;
  DateTime? startTime;
  Duration elapsedTime = Duration.zero;

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
    double val = (_controller.value * maxDuration);
    List<Color> gradientColors = const [
      Color(0xffFF0069),
      Color(0xffFED602),
      Color(0xff7639FB),
      Color(0xffD500C5),
      Color(0xffFF7A01),
      Color(0xffFF0069),
    ];
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
              const SizedBox(
                height: 50,
              ),
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
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CustomPaint(
                              painter: LiquidPainter(
                                _controller.value * maxDuration,
                                maxDuration.toDouble(),
                              ),
                            ),
                          ),
                          CustomPaint(
                              painter: RadialProgressPainter(
                            value: _controller.value * maxDuration,
                            backgroundGradientColors: gradientColors,
                            minValue: 0,
                            maxValue: maxDuration.toDouble(),
                          )),
                        ],
                      ),
                    );
                  }),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white54,
                      width: 2,
                    ),
                    shape: BoxShape.circle),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isDetoxing) {
                        _controller.reset();
                      } else {
                        _controller.reset();
                        _controller.forward();
                      }
                      isDetoxing = !isDetoxing;
                    });
                  },
                  child: AnimatedContainer(
                    height: isDetoxing ? 25 : 60,
                    width: isDetoxing ? 25 : 60,
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isDetoxing ? 4 : 100),
                      color: const Color.fromARGB(66, 0, 0, 0),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isDetoxing ? stopDetox : startDetox,
                child: Text(isDetoxing ? 'Stop Detox' : 'Start Detox'),
              ),
            ],
          ),
        ));
  }
}
