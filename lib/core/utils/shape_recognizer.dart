import 'dart:math';
import 'package:flutter/material.dart';

class ShapeRecognizer {
  /// Analyzes a list of points and returns geometrically perfect points
  /// if a shape is recognized, or null otherwise.
  static List<Offset>? recognizeShape(
    List<Offset> points, {
    double epsilon = 20.0, // Back to standard epsilon, logic should be smarter
  }) {
    if (points.length < 5) return null;

    final simplified = _douglasPeucker(points, epsilon);
    if (simplified.length < 2) return null;

    // Increased closure tolerance from 50 to 80
    final bool isClosed = _distance(points.first, points.last) < 80.0;

    if (!isClosed) {
      // Line Check
      if (_isLine(points)) {
        return [points.first, points.last];
      }
      return null;
    }

    simplified[simplified.length - 1] = simplified.first;

    // Triangle Check
    if (simplified.length == 4) {
      if (_isValidPolygon(simplified)) return simplified;
    }

    // Rectangle check
    if (simplified.length == 5) {
      if (_isValidPolygon(simplified)) return _regularizeRectangle(simplified);
    }

    // Advanced fallbacks for jittery drawings
    // If it has too many points but looks like a circle
    if (_isCircle(points)) {
      return _createCircle(points);
    }

    return null;
  }

  /// Checks if the angles between segments of the polygon are realistic for a drawn shape.
  /// Prevents weird "teardrop" or collapsed shapes from being recognized as polygons.
  static bool _isValidPolygon(List<Offset> poly) {
    if (poly.length < 4) return false;
    for (int i = 0; i < poly.length - 1; i++) {
      int prev = i == 0 ? poly.length - 2 : i - 1;
      int next = i + 1;

      Offset p0 = poly[prev];
      Offset p1 = poly[i];
      Offset p2 = poly[next];

      // Calculate angle at vertex p1
      double a = _distance(p1, p0);
      double b = _distance(p1, p2);
      double c = _distance(p0, p2);

      if (a == 0 || b == 0) return false;

      double cosAngle = (a * a + b * b - c * c) / (2 * a * b);
      cosAngle = cosAngle.clamp(-1.0, 1.0);
      double angle = acos(cosAngle);

      // If angle is too sharp (e.g. less than 15 degrees) or too flat (close to 180), reject
      if (angle < (pi / 12) || angle > (11 * pi / 12)) {
        return false;
      }
    }
    return true;
  }

  static double _distance(Offset p1, Offset p2) => (p1 - p2).distance;

  static double _perpendicularDistance(
    Offset pt,
    Offset lineStart,
    Offset lineEnd,
  ) {
    double dx = lineEnd.dx - lineStart.dx;
    double dy = lineEnd.dy - lineStart.dy;

    // line is a point
    if (dx == 0 && dy == 0) return _distance(pt, lineStart);

    double length = sqrt(dx * dx + dy * dy);
    return ((dy * pt.dx -
                dx * pt.dy +
                lineEnd.dx * lineStart.dy -
                lineEnd.dy * lineStart.dx)
            .abs()) /
        length;
  }

  static List<Offset> _douglasPeucker(List<Offset> points, double epsilon) {
    if (points.length < 3) return points;

    double dmax = 0;
    int index = 0;
    int end = points.length - 1;

    for (int i = 1; i < end; i++) {
      double d = _perpendicularDistance(points[i], points[0], points[end]);
      if (d > dmax) {
        index = i;
        dmax = d;
      }
    }

    List<Offset> result = [];
    if (dmax > epsilon) {
      List<Offset> recResults1 = _douglasPeucker(
        points.sublist(0, index + 1),
        epsilon,
      );
      List<Offset> recResults2 = _douglasPeucker(
        points.sublist(index, end + 1),
        epsilon,
      );

      result.addAll(recResults1.sublist(0, recResults1.length - 1));
      result.addAll(recResults2);
    } else {
      result = [points[0], points[end]];
    }

    return result;
  }

  static bool _isLine(List<Offset> points) {
    Offset start = points.first;
    Offset end = points.last;
    final length = _distance(start, end);
    if (length < 20) return false;

    double maxDist = 0;
    for (var p in points) {
      var d = _perpendicularDistance(p, start, end);
      if (d > maxDist) maxDist = d;
    }
    // Relaxed line tolerance from 15 to 30
    return maxDist < 30.0;
  }

  static bool _isCircle(List<Offset> points) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;
    for (var p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    Offset center = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    double avgRadius = ((maxX - minX) + (maxY - minY)) / 4;

    if (avgRadius < 10) return false;

    double maxDeviation = 0;
    for (var p in points) {
      double r = _distance(center, p);
      double deviation = (r - avgRadius).abs();
      if (deviation > maxDeviation) maxDeviation = deviation;
    }

    // Strict circle tolerance to prevent teardrops from being circles
    return maxDeviation / avgRadius < 0.25; // 25% variance
  }

  static List<Offset> _createCircle(List<Offset> points) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;
    for (var p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    Offset center = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    double radiusX = (maxX - minX) / 2;
    double radiusY = (maxY - minY) / 2;

    List<Offset> circlePoints = [];
    int segments = 60;
    for (int i = 0; i <= segments; i++) {
      double angle = (i * 2 * pi) / segments;
      circlePoints.add(
        Offset(
          center.dx + radiusX * cos(angle),
          center.dy + radiusY * sin(angle),
        ),
      );
    }
    return circlePoints;
  }

  static List<Offset> _regularizeRectangle(List<Offset> quad) {
    bool axisAligned = true;
    for (int i = 0; i < 4; i++) {
      Offset p1 = quad[i];
      Offset p2 = quad[i + 1];
      double angle = atan2(p2.dy - p1.dy, p2.dx - p1.dx).abs();
      double angleMod = angle % (pi / 2);
      if (angleMod > 0.3 && angleMod < (pi / 2 - 0.3)) {
        axisAligned = false;
        break;
      }
    }

    if (axisAligned) {
      double minX = double.infinity, minY = double.infinity;
      double maxX = -double.infinity, maxY = -double.infinity;
      for (int i = 0; i < 4; i++) {
        if (quad[i].dx < minX) minX = quad[i].dx;
        if (quad[i].dx > maxX) maxX = quad[i].dx;
        if (quad[i].dy < minY) minY = quad[i].dy;
        if (quad[i].dy > maxY) maxY = quad[i].dy;
      }
      return [
        Offset(minX, minY),
        Offset(maxX, minY),
        Offset(maxX, maxY),
        Offset(minX, maxY),
        Offset(minX, minY),
      ];
    }
    return quad;
  }
}
