import 'package:flutter/material.dart';

class CoinsDisplay extends StatelessWidget {
  final int coins;
  const CoinsDisplay({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(
            right: 16.0, top: 20.0), // Adjusted margin to move left
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8.0)
            ]),
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
            )
          ],
        ));
  }
}
