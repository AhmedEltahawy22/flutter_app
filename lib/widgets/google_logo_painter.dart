import 'package:flutter/material.dart';
import 'dart:math';

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset center = Offset(r, r);
    final double strokeW = r * 0.30;
    final double arcR = r - strokeW / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    // Red — top arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: arcR), 3.84, 2.07, false, paint);

    // Yellow — bottom-left arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: arcR), 2.29, 1.50, false, paint);

    // Green — bottom arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: arcR), 1.57, 0.78, false, paint);

    // Blue — right arc (gap at top-right for the bar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: arcR), 0.35, 1.22, false, paint);

    // Blue horizontal bar
    paint.style = PaintingStyle.fill;
    final double barTop = center.dy - strokeW / 2;
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 1, barTop, r - strokeW * 0.20, strokeW),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}