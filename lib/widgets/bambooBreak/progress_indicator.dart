import 'package:flutter/material.dart';
import 'package:pandatime/components/custom/processIndicator/progress_bar.dart';

/// Bamboo Break circular progress indicator
class BambooBreakProcessIndicator extends StatelessWidget {
  final AnimationController animationController;

  const BambooBreakProcessIndicator(
      {super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = const [
      Color(0xffFF0069),
      Color(0xffFED602),
      Color(0xff7639FB),
      Color(0xffD500C5),
      Color(0xffFF7A01),
      Color(0xffFF0069),
    ];

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        return Container(
          height: 300,
          width: 300,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/panda.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              CustomPaint(
                painter: RadialProgressPainter(
                  value: animationController.value,
                  backgroundGradientColors: gradientColors,
                  minValue: 0,
                  maxValue: 1, // Normalize to 1 for the progress
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
