import 'package:flutter/material.dart';
import 'dart:math';

class RadialProgressPainter extends CustomPainter {
  final double value;
  final List<Color> backgroundGradientColors;
  final double minValue;
  final double maxValue;

  RadialProgressPainter({
    required this.value,
    required this.backgroundGradientColors,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // circle's diameter // taking min side as diameter
    final double diameter = min(size.height, size.width);
    // Radius
    final double radius = diameter / 2;
    // Center cordinate
    final double centerX = radius;
    final double centerY = radius;

    const double strokeWidth = 6;

    // Paint for the progress with gradient colors.
    final Paint progressPaint = Paint()
      ..shader = SweepGradient(
        colors: backgroundGradientColors,
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        tileMode: TileMode.repeated,
      ).createShader(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Paint for the progress track.
    final Paint progressTrackPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Calculate the start and sweep angles to draw the progress arc.
    double startAngle = -pi / 2;
    double sweepAngle = 2 * pi * value / maxValue;

    // Drawing track.
    canvas.drawCircle(Offset(centerX, centerY), radius, progressTrackPaint);
    // Drawing progress.
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

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
