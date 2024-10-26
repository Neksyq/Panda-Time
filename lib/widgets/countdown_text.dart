import 'package:flutter/material.dart';
import 'package:pandatime/utils/time_formatter.dart';

/// Builds the formatted countdown text
class CountdownText extends StatelessWidget {
  final int time;
  const CountdownText({super.key, required this.time});
  @override
  Widget build(BuildContext context) {
    return Text(
      formatTime(time),
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}
