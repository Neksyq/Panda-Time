import 'package:flutter/material.dart';
import 'package:pandatime/components/custom/processIndicator/progress_bar.dart';

/// Bamboo Break circular progress indicator
class BambooBreakProcessIndicator extends StatelessWidget {
  final AnimationController animationController;
  final bool isActive;

  const BambooBreakProcessIndicator(
      {super.key, required this.animationController, required this.isActive});

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
          height: 225,
          width: 225,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipOval(
                child: Image.asset(
                  isActive
                      ? 'assets/images/pandaBambooBlizzMode.gif'
                      : 'assets/images/pandaOutOfBambooForest.png',
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
