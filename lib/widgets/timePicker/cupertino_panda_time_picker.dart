import 'package:flutter/cupertino.dart';

/// Widget for displaying the Cupertino picker to select detox duration.
class CupertinoPandaTimePicker extends StatelessWidget {
  final int selectedIndex;
  final List<int> times;
  final Function(int) onItemChanged;

  const CupertinoPandaTimePicker({
    Key? key,
    required this.selectedIndex,
    required this.times,
    required this.onItemChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(
          initialItem: selectedIndex,
        ),
        onSelectedItemChanged: onItemChanged,
        children: times.map((time) {
          return Center(
            child: Text(
              '$time minutes',
              style: const TextStyle(fontSize: 18),
            ),
          );
        }).toList(),
      ),
    );
  }
}
