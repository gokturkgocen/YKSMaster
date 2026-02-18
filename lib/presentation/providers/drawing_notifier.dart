import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../widgets/drawing_path.dart';
import 'drawing_state.dart';

/// StateNotifier for managing drawing state with Riverpod
class DrawingNotifier extends StateNotifier<DrawingState> {
  DrawingNotifier() : super(const DrawingState());

  /// Start a new stroke at the given position
  void startStroke(Offset position) {
    state = state.copyWith(currentPathPoints: [position]);
  }

  /// Add a point to the current stroke
  void updateStroke(Offset position) {
    final updatedPoints = [...state.currentPathPoints, position];
    state = state.copyWith(currentPathPoints: updatedPoints);
  }

  /// Finalize the current stroke and add to paths
  void endStroke() {
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

  /// Save current paths for a specific page ID
  void savePage(String pageId) {
    if (pageId.isEmpty) return;

    // Create new map to ensure immutability
    final newSaved = Map<String, List<DrawingPath>>.from(state.savedDrawings);
    newSaved[pageId] = List.from(state.paths);

    state = state.copyWith(savedDrawings: newSaved);
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
