import 'package:flutter/material.dart';
import 'dart:math';

class KnobPainter extends CustomPainter {
  final double angle;

  KnobPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final knobPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -135 * (pi / 180.0);
    final sweepAngle = 270 * (pi / 180.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      knobPaint,
    );

    final indicatorPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final indicatorAngle = startAngle + angle * sweepAngle;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      indicatorAngle - startAngle,
      false,
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(KnobPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
