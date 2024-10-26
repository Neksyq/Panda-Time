import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pandatime/utils/localStorage/coins_storage.dart';
import 'package:pandatime/widgets/bambooBreak/control_button.dart';
import 'package:pandatime/widgets/bambooBreak/progress_indicator.dart';
import 'package:pandatime/widgets/bambooBreak/set_time_button.dart';
import 'package:pandatime/widgets/bambooBreak/status.dart';
import 'package:pandatime/widgets/coins/coins_display.dart';
import 'package:pandatime/widgets/countdown_text.dart';
import 'package:pandatime/widgets/xpBar/xp_bar.dart';
import 'package:pandatime/widgets/timePicker/cupertino_panda_time_picker.dart';
import 'package:pandatime/widgets/timePicker/time_picker_header.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pandatime/widgets/messages/flash_message_screen.dart';

class BambooBreakTrackerScreen extends StatefulWidget {
  const BambooBreakTrackerScreen({super.key});

  @override
  _BambooBreakTrackerScreenState createState() =>
      _BambooBreakTrackerScreenState();
}

class _BambooBreakTrackerScreenState extends State<BambooBreakTrackerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController
      _animationController; // Animation controller for the progress indicator
  double earnedPointsPerSession = 0;
  Timer? _countdownTimer; // Timer for countdown
  int remainingTime = 300; // Countdown timer in seconds (default 5 minutes)
  bool isOnBambooBreak = false; // Tracks if Bamboo Break session is active
  int temporaryTime =
      300; // Temporary variable for holding selected time during picker interaction (default 5 minutes)

  final int currentLevel = 3; // Example current level
  final double progress = 0.6; // Example progress (60%)

  final GlobalKey<CoinsDisplayState> _coinsDisplayKey = GlobalKey();
  final GlobalKey<XPBarState> _xpBarKey = GlobalKey();
  // List of selectable times for the BambooBreak session (in minutes)
  final List<int> bambooBreakTimes =
      List.generate(24 * 60 ~/ 5, (index) => (index + 1) * 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // To observe lifecycle events of the app
    _initializeAnimationController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print('use leaves');
      _stopBambooBreak();
    } else if (state == AppLifecycleState.resumed) {
      print('user returns');
    }
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Dummy initial duration
    )..addListener(() {
        setState(() {}); // Rebuild widget to update progress indicator
      });
  }

  /// Starts or resumes the BambooBreak session
  void _startBambooBreak() {
    setState(() {
      WakelockPlus.enable();
      isOnBambooBreak = true;
    });

    if (_animationController.isDismissed) {
      _animationController.duration = Duration(seconds: remainingTime);
      _animationController.forward();
    } else {
      _animationController.forward();
    }

    _startCountdown();
  }

  /// Stops (pauses) the BambooBreak session
  void _stopBambooBreak() {
    setState(() {
      WakelockPlus.disable();
      isOnBambooBreak = false;
      _animationController.stop();
      _countdownTimer?.cancel();
    });
  }

  /// Starts or continues the countdown timer
  void _startCountdown() {
    const xp = 100.0;
    double currentXP = _xpBarKey.currentState!.xp;
    _xpBarKey.currentState?.updateXP(currentXP + xp);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--; // Decrease remaining time by 1 second
        });
      } else {
        earnedPointsPerSession = 10.0;
        double availableCoins = _coinsDisplayKey.currentState!.coins;
        _coinsDisplayKey.currentState
            ?.updateCoins(earnedPointsPerSession + availableCoins);
        _stopBambooBreak(); // Stop BambooBreak when countdown reaches 0
        showFlashMessage(
          context,
          "Panda-tastic!",
          "You've earned $earnedPointsPerSession bamboo coins!",
          backgroundColor: Colors.green,
        );
      }
    });
  }

  /// Opens the time picker to select BambooBreak duration
  void _showBambooBreakTimePicker(BuildContext context) {
    int selectedIndex =
        bambooBreakTimes.indexOf(remainingTime ~/ 60); // Initial index
    temporaryTime =
        remainingTime; // Initialize temporary time to current remaining time
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              PickerHeader(
                  leftTopText: 'Select Bamboo Break Duration',
                  rightTopText: 'Done',
                  onDonePressed: () {
                    // Update remaining time only when "Done" is pressed
                    setState(() {
                      if (temporaryTime > 0) {
                        remainingTime = temporaryTime;
                        _animationController.duration =
                            Duration(seconds: remainingTime);
                        _animationController.reset();
                      }
                    });
                    Navigator.of(context).pop();
                  }),
              CupertinoPandaTimePicker(
                  selectedIndex: selectedIndex,
                  times: bambooBreakTimes,
                  onItemChanged: (index) {
                    setState(() {
                      temporaryTime =
                          bambooBreakTimes[index] * 60; // Update temporary time
                    });
                  }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [CoinsDisplay(key: _coinsDisplayKey)],
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 10.0), // Adjust the top padding here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            XPBar(key: _xpBarKey),
            const SizedBox(height: 30),
            CurrentStatusText(
                text1: 'Bamboo Bliss Mode...',
                text2: 'Out of the Bamboo Forest',
                isActive: isOnBambooBreak),
            const SizedBox(height: 30),
            BambooBreakProcessIndicator(
                animationController: _animationController),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            CountdownText(time: remainingTime),
            const SizedBox(height: 40),
            OpenTimePickerButton(
                isEnabled: isOnBambooBreak,
                buttonText: 'Set Duration',
                onButtonPressed: () => {_showBambooBreakTimePicker(context)}),
            const SizedBox(height: 20),
            ControlButton(
                isActive: isOnBambooBreak,
                textOnActive: 'Stop Bamboo Break',
                textOnNonActive: 'Start Bamboo Break',
                executeOnActive: () => {_stopBambooBreak()},
                executeOnNonActive: () => {_startBambooBreak()}),
          ],
        ),
      ),
    );
  }
}
