import 'package:flutter/material.dart';

/// Builds the header for the time picker
class PickerHeader extends StatelessWidget {
  final VoidCallback onDonePressed;
  final String leftTopText;
  final String rightTopText;

  const PickerHeader({
    super.key,
    required this.leftTopText,
    required this.rightTopText,
    required this.onDonePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Using a non-const Text because leftTopText is not a constant
          Text(
            leftTopText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onDonePressed,
            // Using a non-const Text because rightTopText is not a constant
            child: Text(
              rightTopText,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
