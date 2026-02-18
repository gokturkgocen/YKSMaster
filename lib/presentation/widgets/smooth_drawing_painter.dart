import 'package:flutter/material.dart';
import 'drawing_path.dart';

/// Advanced CustomPainter with smooth ink rendering (Goodnotes style)
class SmoothDrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;
  
  SmoothDrawingPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    for (final drawingPath in paths) {
      final paint = Paint()
        ..color = drawingPath.color
        ..strokeWidth = drawingPath.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true; // Smooth anti-aliased edges

      if (drawingPath.tool == DrawingTool.eraser) {
        paint.blendMode = BlendMode.clear;
      }

      // Draw the smoothed path
      final smoothPath = drawingPath.toSmoothPath();
      canvas.drawPath(smoothPath, paint);
    }
  }

  @override
  bool shouldRepaint(SmoothDrawingPainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
