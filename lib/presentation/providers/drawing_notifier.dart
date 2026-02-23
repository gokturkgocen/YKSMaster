import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/drawing_path.dart';
import '../../core/utils/shape_recognizer.dart';
import 'drawing_state.dart';

/// StateNotifier for managing drawing state with Riverpod
class DrawingNotifier extends StateNotifier<DrawingState> {
  static const _keyDrawings = 'saved_drawings';

  Timer? _holdTimer;
  bool _isShapeSnapped = false;
  Offset? _lastTimerPoint; // Track the point where the timer was last reset

  DrawingNotifier() : super(const DrawingState()) {
    _loadPersistedDrawings();
  }

  /// Load persisted drawings from SharedPreferences on init
  Future<void> _loadPersistedDrawings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDrawings);
    if (jsonString == null) return;

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, List<DrawingPath>> loaded = {};
      decoded.forEach((pageId, pathsJson) {
        final List<dynamic> pathsList = pathsJson as List<dynamic>;
        loaded[pageId] = pathsList
            .map((p) => DrawingPath.fromJson(p as Map<String, dynamic>))
            .toList();
      });
      state = state.copyWith(savedDrawings: loaded);
    } catch (e) {
      // Corrupted data — ignore and start fresh
    }
  }

  /// Persist all saved drawings to SharedPreferences
  Future<void> _persistDrawings() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> serialized = {};
    state.savedDrawings.forEach((pageId, paths) {
      serialized[pageId] = paths.map((p) => p.toJson()).toList();
    });
    await prefs.setString(_keyDrawings, jsonEncode(serialized));
  }

  /// Start a new stroke at the given position
  void startStroke(Offset position) {
    _holdTimer?.cancel();
    _isShapeSnapped = false;
    _lastTimerPoint = position;
    state = state.copyWith(currentPathPoints: [position]);

    // Start initial timer
    if (state.selectedTool == DrawingTool.pen) {
      _holdTimer = Timer(const Duration(milliseconds: 600), _checkAndSnapShape);
    }
  }

  /// Add a point to the current stroke
  void updateStroke(Offset position) {
    if (_isShapeSnapped) return; // Wait until pen is lifted once snapped

    final updatedPoints = [...state.currentPathPoints, position];
    state = state.copyWith(currentPathPoints: updatedPoints);

    if (state.selectedTool == DrawingTool.pen) {
      // Only reset the timer if the movement is significant (human jitter tolerance)
      if (_lastTimerPoint != null) {
        final distance = (position - _lastTimerPoint!).distance;
        if (distance > 3.0) {
          // 3 logical pixels of tolerance
          _holdTimer?.cancel();
          _lastTimerPoint = position;
          _holdTimer = Timer(
            const Duration(milliseconds: 600),
            _checkAndSnapShape,
          );
        }
      } else {
        _lastTimerPoint = position;
      }
    }
  }

  void _checkAndSnapShape() {
    if (state.currentPathPoints.length < 10) return;

    final snappedPoints = ShapeRecognizer.recognizeShape(
      state.currentPathPoints,
    );
    if (snappedPoints != null) {
      HapticFeedback.lightImpact();
      _isShapeSnapped = true;
      state = state.copyWith(currentPathPoints: snappedPoints);
    }
  }

  /// Finalize the current stroke and add to paths
  void endStroke() {
    _holdTimer?.cancel();
    _lastTimerPoint = null;
    if (state.currentPathPoints.isEmpty) return;

    final newPath = DrawingPath(
      points: List.from(state.currentPathPoints),
      color: state.selectedTool == DrawingTool.pen
          ? state.penColor
          : Colors.transparent,
      strokeWidth: state.selectedTool == DrawingTool.pen
          ? state.penWidth
          : state.eraserWidth,
      tool: state.selectedTool,
    );

    state = state.copyWith(
      paths: [...state.paths, newPath],
      currentPathPoints: [],
    );
  }

  /// Undo the last completed stroke
  void undo() {
    if (!state.canUndo) return;

    final updatedPaths = List<DrawingPath>.from(state.paths)..removeLast();
    state = state.copyWith(paths: updatedPaths);
  }

  /// Clear all strokes
  void clearAll() {
    state = state.copyWith(paths: [], currentPathPoints: []);
  }

  /// Change the active drawing tool
  void changeTool(DrawingTool tool) {
    state = state.copyWith(selectedTool: tool);
  }

  /// Change pen color
  void changePenColor(Color color) {
    state = state.copyWith(penColor: color);
  }

  /// Change pen width
  void changePenWidth(double width) {
    state = state.copyWith(penWidth: width);
  }

  /// Erase any stroke that contains the given point (stroke deletion eraser)
  void eraseStrokeAtPoint(Offset point) {
    final updatedPaths = state.paths.where((path) {
      return !path.containsPoint(point, threshold: state.eraserWidth / 2);
    }).toList();

    state = state.copyWith(paths: updatedPaths, eraserPosition: point);
  }

  /// Update eraser cursor position
  void updateEraserPosition(Offset position) {
    state = state.copyWith(eraserPosition: position);
  }

  /// Clear eraser position (hide cursor)
  void clearEraserPosition() {
    state = state.copyWith(eraserPosition: null);
  }

  /// Toggle canvas background between light and dark
  void toggleCanvasLightMode() {
    state = state.copyWith(isCanvasLightMode: !state.isCanvasLightMode);
  }

  /// Save current paths for a specific page ID (in-memory + disk)
  void savePage(String pageId) {
    if (pageId.isEmpty) return;

    // Create new map to ensure immutability
    final newSaved = Map<String, List<DrawingPath>>.from(state.savedDrawings);
    newSaved[pageId] = List.from(state.paths);

    state = state.copyWith(savedDrawings: newSaved);
    _persistDrawings(); // Write to disk
  }

  /// Load paths for a specific page ID
  void loadPage(String pageId) {
    if (pageId.isEmpty) {
      clearAll();
      return;
    }

    final paths = state.savedDrawings[pageId] ?? [];

    // Replace current paths with loaded ones
    state = state.copyWith(
      paths: List.from(paths),
      currentPathPoints: [], // Clear any active stroke
    );
  }
}

/// Provider for the drawing notifier
final drawingProvider = StateNotifierProvider<DrawingNotifier, DrawingState>(
  (ref) => DrawingNotifier(),
);
