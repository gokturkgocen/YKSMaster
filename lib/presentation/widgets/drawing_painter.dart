import 'package:flutter/material.dart';

/// Custom painter for drawing canvas
/// Provides low-latency drawing experience for tablet pen/finger input
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;
  final Color strokeColor;
  final double strokeWidth;

  DrawingPainter({
    required this.points,
    this.strokeColor = const Color(0xFF3A3A3A),
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != null && points[i + 1].offset != null) {
        canvas.drawLine(
          points[i].offset!,
          points[i + 1].offset!,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

/// Represents a single point in the drawing
class DrawingPoint {
  final Offset? offset;

  DrawingPoint({this.offset});
}
