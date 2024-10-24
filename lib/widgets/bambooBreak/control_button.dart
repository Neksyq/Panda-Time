import 'package:flutter/material.dart';

/// Builds the start/stop control button

class ControlButton extends StatelessWidget {
  final bool isActive;
  final String textOnActive;
  final String textOnNonActive;
  final VoidCallback executeOnActive;
  final VoidCallback executeOnNonActive;

  const ControlButton(
      {super.key,
      required this.isActive,
      required this.textOnActive,
      required this.textOnNonActive,
      required this.executeOnActive,
      required this.executeOnNonActive});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isActive ? executeOnActive : executeOnNonActive,
      child: Text(isActive ? 'Stop Bamboo Break' : 'Start Bamboo Break'),
    );
  }
}
