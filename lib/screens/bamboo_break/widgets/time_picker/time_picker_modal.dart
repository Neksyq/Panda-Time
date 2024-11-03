import 'package:flutter/material.dart';
import 'package:pandatime/widgets/timePicker/cupertino_panda_time_picker.dart';
import 'package:pandatime/widgets/timePicker/time_picker_header.dart';

class TimePicker extends StatelessWidget {
  final int initialTime;
  final List<int> bambooBreakTimes;
  final ValueChanged<int> onTimeSelected;
  final VoidCallback onDonePressed;

  const TimePicker({
    super.key,
    required this.initialTime,
    required this.bambooBreakTimes,
    required this.onTimeSelected,
    required this.onDonePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          PickerHeader(
            leftTopText: 'Select Bamboo Break Duration',
            rightTopText: 'Done',
            onDonePressed: onDonePressed,
          ),
          CupertinoPandaTimePicker(
            selectedIndex: initialTime,
            times: bambooBreakTimes,
            onItemChanged: onTimeSelected,
          ),
        ],
      ),
    );
  }
}
