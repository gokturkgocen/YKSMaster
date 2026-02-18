import 'package:flutter/material.dart';

/// Tool types available in the drawing toolbar
enum DrawingTool {
  pen,
  eraser,
  lasso,
  pointer, // For interaction mode (selecting answers, scrolling)
}

/// Represents a complete drawing stroke/path
class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final DrawingTool tool;

  DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });

  /// Creates a smoothed version of this path using Bezier curves
  Path toSmoothPath() {
    if (points.isEmpty) return Path();
    if (points.length == 1) {
      return Path()
        ..addOval(Rect.fromCircle(center: points[0], radius: strokeWidth / 2));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    // Use quadratic Bezier curves for smooth interpolation
    for (int i = 1; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, controlPoint.dx, controlPoint.dy);
    }

    // Add the last point
    if (points.length > 1) {
      final lastPoint = points.last;
      path.lineTo(lastPoint.dx, lastPoint.dy);
    }

    return path;
  }

  /// Check if a point is near this path (for eraser hit testing)
  bool containsPoint(Offset point, {double threshold = 20.0}) {
    for (final pathPoint in points) {
      final distance = (pathPoint - point).distance;
      if (distance <= threshold) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
    'color': color.toARGB32(),
    'strokeWidth': strokeWidth,
    'tool': tool.index,
  };

  factory DrawingPath.fromJson(Map<String, dynamic> json) {
    return DrawingPath(
      points: (json['points'] as List)
          .map((p) => Offset(p['dx'] as double, p['dy'] as double))
          .toList(),
      color: Color(json['color'] as int),
      strokeWidth: json['strokeWidth'] as double,
      tool: DrawingTool.values[json['tool'] as int],
    );
  }
}
