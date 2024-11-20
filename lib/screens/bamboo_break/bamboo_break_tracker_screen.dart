import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandatime/components/control_button.dart';
import 'package:pandatime/screens/bamboo_break/widgets/progress_indicator.dart';
import 'package:pandatime/screens/bamboo_break/widgets/time_picker/time_picker_button.dart';
import 'package:pandatime/components/status.dart';
import 'package:pandatime/widgets/coins/coins_display.dart';
import 'package:pandatime/screens/bamboo_break/widgets/countdown_text.dart';
import 'package:pandatime/widgets/navigation/custom_drawer.dart';
import 'package:pandatime/widgets/xpBar/xp_bar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pandatime/screens/bamboo_break/flash_message_screen.dart';

import 'widgets/time_picker/time_picker_modal.dart';

class BambooBreakTimer {
  static final BambooBreakTimer _instance = BambooBreakTimer._internal();

  factory BambooBreakTimer() {
    return _instance;
  }

  BambooBreakTimer._internal();

  static const int defaultBreakTime = 300;
  int remainingTime = defaultBreakTime;
  bool isOnBreak = false;
  double earnedPointsPerSession = 0;
  Timer? countdownTimer;

  void reset() {
    remainingTime = defaultBreakTime;
    isOnBreak = false;
    countdownTimer?.cancel();
  }
}

class BambooBreakTrackerScreen extends StatefulWidget {
  const BambooBreakTrackerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BambooBreakTrackerScreenState createState() =>
      _BambooBreakTrackerScreenState();
}

class _BambooBreakTrackerScreenState extends State<BambooBreakTrackerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.example.pandatime/screen');

  late AnimationController _animationController;
  final timer = BambooBreakTimer();
  final GlobalKey<CoinsDisplayState> _coinsDisplayKey = GlobalKey();
  final GlobalKey<XPBarState> _xpBarKey = GlobalKey();
  final List<int> breakTimes =
      List.generate(24 * 60 ~/ 5, (index) => (index + 1) * 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimationController();
    _initializePlatformChannel();
    if (timer.isOnBreak) {
      _startBreak(resuming: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    timer.countdownTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _initializePlatformChannel() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onScreenOff':
          print('Screen was locked, continuing detox');
          break;
        case 'onScreenOn':
          print('Screen is unlocked, continuing detox');
          break;
        case 'onAppPaused':
          print('App is switched, stopping detox');
          if (timer.isOnBreak) {
            _stopBreak();
          }
          break;
        case 'onAppResumed':
          print('App is active');
          break;
        default:
          print('Unknown method: ${call.method}');
          break;
      }
    });
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: timer.remainingTime),
    )..addListener(() {
        setState(() {});
      });
  }

  void _startBreak({bool resuming = false}) {
    setState(() {
      timer.isOnBreak = true;
      WakelockPlus.enable();
      _animationController.duration = Duration(seconds: timer.remainingTime);
      if (!resuming) {
        _animationController.forward();
      }
    });

    _startCountdown();
  }

  void _stopBreak() {
    setState(() {
      timer.isOnBreak = false;
      WakelockPlus.disable();
      _animationController.stop();
      timer.countdownTimer?.cancel();
    });
  }

  void _startCountdown() {
    timer.countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timerInstance) {
      if (timer.remainingTime > 0) {
        setState(() {
          timer.remainingTime--;
        });
      } else {
        _completeBreak();
      }
    });
  }

  void _completeBreak() {
    timer.earnedPointsPerSession = 10;
    _updateCoins();
    _stopBreak();
    _showCompletionMessage();
    _animationController.reset();
    setState(() {
      timer.remainingTime = BambooBreakTimer.defaultBreakTime;
    });
  }

  void _updateCoins() {
    final currentCoins = _coinsDisplayKey.currentState?.coins ?? 0;
    _coinsDisplayKey.currentState
        ?.updateCoins(currentCoins + timer.earnedPointsPerSession);
  }

  void _showCompletionMessage() {
    showFlashMessage(
      context,
      "Panda-tastic!",
      "You've earned ${timer.earnedPointsPerSession} bamboo coins!",
      backgroundColor: Colors.green,
    );
  }

  void _showTimePicker(BuildContext context) {
    var currentSelectedTime = BambooBreakTimer.defaultBreakTime;
    showModalBottomSheet(
      context: context,
      builder: (_) => TimePicker(
        initialTime: breakTimes.indexOf(timer.remainingTime ~/ 60),
        bambooBreakTimes: breakTimes,
        onTimeSelected: (selectedTime) {
          currentSelectedTime = breakTimes[selectedTime] * 60;
        },
        onDonePressed: () {
          // Set remaining time and close the picker
          setState(() {
            timer.remainingTime = currentSelectedTime;
            _animationController.duration =
                Duration(seconds: timer.remainingTime);
            _animationController.reset();
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: timer.isOnBreak
            ? Container()
            : Builder(
                builder: (context) => IconButton(
                  color: Colors.green,
                  padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                  icon: const Icon(Icons.menu),
                  iconSize: 36.0,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
        actions: [CoinsDisplay(key: _coinsDisplayKey)],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          XPBar(key: _xpBarKey),
          const SizedBox(height: 20),
          CurrentStatusText(
            text1: 'Bamboo Bliss Mode...',
            text2: 'Out of the Bamboo Forest',
            isActive: timer.isOnBreak,
          ),
          const SizedBox(height: 30),
          BambooBreakProcessIndicator(
            animationController: _animationController,
            isActive: timer.isOnBreak,
          ),
          const SizedBox(height: 20),
          CountdownText(time: timer.remainingTime),
          const SizedBox(height: 20),
          OpenTimePickerButton(
            isEnabled: !timer.isOnBreak,
            buttonText: 'Set Duration',
            onButtonPressed: () => _showTimePicker(context),
          ),
          const SizedBox(height: 20),
          ControlButton(
            isActive: timer.isOnBreak,
            textOnActive: 'Cancel Bamboo Break',
            textOnNonActive: 'Start Bamboo Break',
            executeOnActive: _stopBreak,
            executeOnNonActive: _startBreak,
          ),
        ],
      ),
    );
  }
}
