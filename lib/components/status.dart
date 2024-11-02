import 'package:flutter/material.dart';

class CurrentStatusText extends StatelessWidget {
  final String text1;
  final String text2;
  final bool isActive;
  const CurrentStatusText(
      {super.key,
      required this.text1,
      required this.text2,
      required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Text(
      isActive ? text1 : text2,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
