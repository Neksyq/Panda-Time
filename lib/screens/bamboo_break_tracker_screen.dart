import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pandatime/widgets/bambooBreak/control_button.dart';
import 'package:pandatime/widgets/bambooBreak/progress_indicator.dart';
import 'package:pandatime/widgets/bambooBreak/set_time_button.dart';
import 'package:pandatime/widgets/bambooBreak/status.dart';
import 'package:pandatime/widgets/coins/coins_display.dart';
import 'package:pandatime/widgets/countdown_text.dart';
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
  Timer? _countdownTimer; // Timer for countdown
  int remainingTime = 300; // Countdown timer in seconds (default 5 minutes)
  bool isOnBambooBreak = false; // Tracks if Bamboo Break session is active
  int temporaryTime =
      300; // Temporary variable for holding selected time during picker interaction (default 5 minutes)

  final GlobalKey<CoinsDisplayState> _coinsDisplayKey = GlobalKey();

  // List of selectable times for the BambooBreak session (in minutes)
  final List<int> bambooBreakTimes =
      List.generate(24 * 60 ~/ 5, (index) => (index + 1) * 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // To observe lifecycle events of the app
    WakelockPlus.enable();
    _initializeAnimationController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _countdownTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
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
      isOnBambooBreak = true;
    });

    if (_animationController.isDismissed) {
      _animationController.duration = Duration(seconds: remainingTime);
      _animationController.forward();
    } else {
      _animationController.forward();
    }

    WakelockPlus.toggle(enable: true);
    _startCountdown();
  }

  /// Stops (pauses) the BambooBreak session
  void _stopBambooBreak() {
    print("Stop");
    setState(() {
      isOnBambooBreak = false;
      _animationController.stop();
      _countdownTimer?.cancel();
    });
    WakelockPlus.toggle(enable: false);
  }

  /// Starts or continues the countdown timer
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--; // Decrease remaining time by 1 second
        });
      } else {
        showFlashMessage(
          context,
          "Success!",
          "You've completed your task!",
          backgroundColor: Colors.green,
        );

        const double earnedCoins = 10.0;
        double currentCoins = _coinsDisplayKey.currentState!.coins;
        _coinsDisplayKey.currentState?.updateCoins(earnedCoins + currentCoins);
        _stopBambooBreak(); // Stop BambooBreak when countdown reaches 0
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CurrentStatusText(
                text1: 'Bamboo Bliss Mode...',
                text2: 'Out of the Bamboo Forest',
                isActive: isOnBambooBreak),
            const SizedBox(height: 30),
            BambooBreakProcessIndicator(
                animationController: _animationController),
            const SizedBox(height: 20),
            CountdownText(time: remainingTime),
            const SizedBox(height: 20),
            OpenTimePickerButton(
                isEnabled: isOnBambooBreak,
                buttonText: 'Set Duration',
                onButtonPressed: () => {_showBambooBreakTimePicker(context)}),
            const SizedBox(height: 10),
            ControlButton(
                isActive: isOnBambooBreak,
                textOnActive: 'Stop Bamboo Break',
                textOnNonActive: 'Start Bamboo Break',
                executeOnActive: () => {_stopBambooBreak()},
                executeOnNonActive: () => {_startBambooBreak()}),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
