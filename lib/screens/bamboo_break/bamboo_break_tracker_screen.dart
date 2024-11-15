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

class BambooBreakTrackerScreen extends StatefulWidget {
  const BambooBreakTrackerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BambooBreakTrackerScreenState createState() =>
      _BambooBreakTrackerScreenState();
}

class _BambooBreakTrackerScreenState extends State<BambooBreakTrackerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const int defaultBreakTime = 300;
  static const platform = MethodChannel('com.example.pandatime/screen');

  late AnimationController _animationController;
  Timer? _countdownTimer;
  bool isOnBreak = false;
  int remainingTime = defaultBreakTime;
  int lastSelectedTime = defaultBreakTime;
  double earnedPointsPerSession = 0;

  final GlobalKey<CoinsDisplayState> _coinsDisplayKey = GlobalKey();
  final GlobalKey<XPBarState> _xpBarKey = GlobalKey();
  final List<int> breakTimes =
      List.generate(24 * 60 ~/ 5, (index) => (index + 1) * 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // To observe lifecycle events of the app
    _initializeAnimationController();
    _initializePlatformChannel();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _countdownTimer?.cancel();
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
          if (isOnBreak) {
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      platform.invokeMethod('onAppPaused');
    } else if (state == AppLifecycleState.resumed) {
      platform.invokeMethod('onAppResumed');
    }
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: remainingTime),
    )..addListener(() {
        setState(() {});
      });
  }

  /// Starts or resumes the break session
  void _startBreak() {
    setState(() {
      isOnBreak = true;
      WakelockPlus.enable();
      _animationController.duration = Duration(seconds: remainingTime);
      _animationController.forward();
    });

    _startCountdown();
  }

  /// Stops (pauses) the break session
  void _stopBreak() {
    setState(() {
      isOnBreak = false;
      WakelockPlus.disable();
      _animationController.stop();
      _countdownTimer?.cancel();
    });
  }

  /// Starts or continues the countdown timer
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingTime > 0) {
        setState(() => remainingTime--);
      } else {
        earnedPointsPerSession = 10;
        _updateCoins();
        _stopBreak();
        _showCompletionMessage();
        remainingTime = lastSelectedTime;
        _animationController.duration = Duration(seconds: remainingTime);
        _animationController.reset();
      }
    });
  }

  void _updateCoins() {
    final currentCoins = _coinsDisplayKey.currentState?.coins ?? 0;
    _coinsDisplayKey.currentState
        ?.updateCoins(currentCoins + earnedPointsPerSession);
  }

  void _showCompletionMessage() {
    showFlashMessage(
      context,
      "Panda-tastic!",
      "You've earned $earnedPointsPerSession bamboo coins!",
      backgroundColor: Colors.green,
    );
  }

  /// Opens the time picker to select break duration
  void _showTimePicker(BuildContext context) {
    var currentSelectedTime = defaultBreakTime;
    showModalBottomSheet(
      context: context,
      builder: (_) => TimePicker(
        initialTime: breakTimes.indexOf(remainingTime ~/ 60),
        bambooBreakTimes: breakTimes,
        onTimeSelected: (selectedTime) {
          currentSelectedTime = breakTimes[selectedTime] * 60;
        },
        onDonePressed: () {
          // Set remaining time and close the picker
          setState(() {
            remainingTime =
                currentSelectedTime; // Apply the selected time in seconds
            _animationController.duration = Duration(seconds: remainingTime);
            _animationController.reset();
          });
          Navigator.of(context).pop(); // Close the modal
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: isOnBreak
            ? Container()
            : Builder(
                builder: (context) => IconButton(
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
              isActive: isOnBreak),
          const SizedBox(height: 30),
          BambooBreakProcessIndicator(
              animationController: _animationController, isActive: isOnBreak),
          const SizedBox(height: 20),
          CountdownText(time: remainingTime),
          const SizedBox(height: 20),
          OpenTimePickerButton(
              isEnabled: isOnBreak,
              buttonText: 'Set Duration',
              onButtonPressed: () => {_showTimePicker(context)}),
          const SizedBox(height: 20),
          ControlButton(
              isActive: isOnBreak,
              textOnActive: 'Stop Bamboo Break',
              textOnNonActive: 'Start Bamboo Break',
              executeOnActive: () => {_stopBreak()},
              executeOnNonActive: () => {_startBreak()}),
        ],
      ),
    );
  }
}

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: isSelected ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading:
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[400]),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
