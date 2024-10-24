import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Builds the button to set BambooBreak duration

class OpenTimePickerButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onButtonPressed;
  final String buttonText;
  const OpenTimePickerButton(
      {super.key,
      required this.isEnabled,
      required this.buttonText,
      required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? null : onButtonPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? Colors.grey : null,
      ),
      child: Text(buttonText),
    );
  }
}
