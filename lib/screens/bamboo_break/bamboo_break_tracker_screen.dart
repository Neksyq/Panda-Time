import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandatime/components/control_button.dart';
import 'package:pandatime/screens/bamboo_break/widgets/progress_indicator.dart';
import 'package:pandatime/screens/bamboo_break/widgets/open_time_picker_button.dart';
import 'package:pandatime/components/status.dart';
import 'package:pandatime/widgets/coins/coins_display.dart';
import 'package:pandatime/screens/bamboo_break/widgets/countdown_text.dart';
import 'package:pandatime/widgets/xpBar/xp_bar.dart';
import 'package:pandatime/widgets/timePicker/cupertino_panda_time_picker.dart';
import 'package:pandatime/widgets/timePicker/time_picker_header.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:pandatime/screens/bamboo_break/flash_message_screen.dart';

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
  int previouslySelectedTime = 300;
  int remainingTime = 300; // Countdown timer in seconds (default 5 minutes)
  bool isOnBambooBreak = false; // Tracks if Bamboo Break session is active
  int temporaryTime =
      300; // Temporary variable for holding selected time during picker interaction (default 5 minutes)

  final int currentLevel = 3; // Example current level
  final double progress = 0.6; // Example progress (60%)
  static const platform = MethodChannel('com.example.pandatime/screen');

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
    _initializePlatformChannel();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
    WakelockPlus.disable();
  }

  void _initializePlatformChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onScreenOff') {
        print('Screen was locked, continuing detox');
      } else if (call.method == 'onScreenOn') {
        print('Screen is unlocked, continuing detox');
      } else if (call.method == 'onAppPaused') {
        print('App is switched, stopping detox');
        if (isOnBambooBreak) {
          _stopBambooBreak();
        }
      } else if (call.method == 'onAppResumed') {
        print('App is active');
      } else {
        print('Unknown method: ${call.method}');
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
        remainingTime = previouslySelectedTime;
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
                        previouslySelectedTime = temporaryTime;
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

  int selectedIndex = 0;

  void onItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer on item tap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [CoinsDisplay(key: _coinsDisplayKey)],
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Drawer(
          backgroundColor: Colors.grey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/profile_pic.png'),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Panda User',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Level 10 • 5000 XP',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    DrawerMenuItem(
                      icon: Icons.home,
                      label: 'Home',
                      isSelected: selectedIndex == 0,
                      onTap: () => onItemTap(0),
                    ),
                    DrawerMenuItem(
                      icon: Icons.show_chart,
                      label: 'Progress',
                      isSelected: selectedIndex == 1,
                      onTap: () => onItemTap(1),
                    ),
                    DrawerMenuItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      isSelected: selectedIndex == 2,
                      onTap: () => onItemTap(2),
                    ),
                    DrawerMenuItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      isSelected: selectedIndex == 3,
                      onTap: () => onItemTap(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0), // Adjust the top padding here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            XPBar(key: _xpBarKey),
            const SizedBox(height: 20),
            CurrentStatusText(
                text1: 'Bamboo Bliss Mode...',
                text2: 'Out of the Bamboo Forest',
                isActive: isOnBambooBreak),
            const SizedBox(height: 30),
            BambooBreakProcessIndicator(
                animationController: _animationController,
                isActive: isOnBambooBreak),
            const SizedBox(height: 20),
            CountdownText(time: remainingTime),
            const SizedBox(height: 20),
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

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerMenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

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
