import 'package:flutter/material.dart';
import 'package:pandatime/utils/localStorage/coins_storage.dart';

class CoinsDisplay extends StatefulWidget {
  const CoinsDisplay({super.key});

  @override
  CoinsDisplayState createState() => CoinsDisplayState();

  void updateCoins(double updatedCoins) {}
}

class CoinsDisplayState extends State<CoinsDisplay> {
  double coins = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  // Load coins from local storage
  Future<void> _loadCoins() async {
    double storedCoins = await CoinsStorage.loadCoins();
    setState(() {
      coins = storedCoins;
    });
  }

  // Method to update coins and save to local storage
  void updateCoins(double newCoins) {
    setState(() {
      coins = newCoins;
    });
    // Save updated coins to local storage
    CoinsStorage.saveCoins(coins);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(right: 16.0, top: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8.0)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/bambooCoin.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 4.0),
          Text(
            '$coins BC',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
