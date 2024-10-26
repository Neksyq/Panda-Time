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
    if (xp < 1000.0) return 1;
    if (xp < 3000.0) return 2;
    if (xp < 6000.0) return 3;
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
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: xp,
            minHeight: 10,
            backgroundColor: Colors.grey[300], // Background color of the bar
            color: Colors.green, // Progress color
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}
