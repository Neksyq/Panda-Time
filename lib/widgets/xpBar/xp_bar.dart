import 'package:flutter/material.dart';
import 'package:pandatime/utils/localStorage/xp_storage.dart';

class XPBar extends StatefulWidget {
  const XPBar({super.key});
  @override
  XPBarState createState() => XPBarState();
}

class XPBarState extends State<XPBar> {
  int currentLevel = 0;
  double xp = 0;

  @override
  void initState() {
    super.initState();
    _loadXp();
  }

  Future<void> _loadXp() async {
    double storedXP = await XPStorage.getXP();
    setState(() {
      xp = storedXP;
    });
  }

  void updateXP(double newXP) {
    XPStorage.saveXP(xp);
    setState(() {
      xp = newXP;
      currentLevel = calculateLevel(xp);
    });
  }

  int calculateLevel(double xp) {
    if (xp < 100.0) return 0;
    if (xp < 500.0) return 1;
    if (xp < 1000.0) return 2;
    if (xp < 1750.0) return 3;
    if (xp < 2500.0) return 4;
    if (xp < 3500.0) return 5;
    if (xp < 4750.0) return 6;
    if (xp < 6250.0) return 7;
    if (xp < 8250.0) return 8;
    if (xp < 10000.0) return 9;
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Level $currentLevel',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
              begin: 0, end: xp / 10000), // Adjust 10000 as max XP for level up
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
