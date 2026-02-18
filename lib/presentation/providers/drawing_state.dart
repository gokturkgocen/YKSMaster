import 'package:flutter/material.dart';
import '../widgets/drawing_path.dart';

/// Immutable state for the drawing system
class DrawingState {
  final List<DrawingPath> paths;
  final List<Offset> currentPathPoints;
  final DrawingTool selectedTool;
  final Color penColor;
  final double penWidth;
  final double eraserWidth;
  final Offset? eraserPosition; // For eraser cursor
  final bool isCanvasLightMode; // Independent canvas background control
  final Map<String, List<DrawingPath>>
  savedDrawings; // Persist drawings per page

  const DrawingState({
    this.paths = const [],
    this.currentPathPoints = const [],
    this.selectedTool = DrawingTool.pen,
    this.penColor = const Color(0xFF1A1A1A),
    this.penWidth = 2.5,
    this.eraserWidth = 60.0,
    this.eraserPosition,
    this.isCanvasLightMode = true,
    this.savedDrawings = const {},
  });

  /// Create a copy with modified fields
  DrawingState copyWith({
    List<DrawingPath>? paths,
    List<Offset>? currentPathPoints,
    DrawingTool? selectedTool,
    Color? penColor,
    double? penWidth,
    double? eraserWidth,
    Offset? eraserPosition,
    bool clearEraserPosition = false,
    bool? isCanvasLightMode,
    Map<String, List<DrawingPath>>? savedDrawings,
  }) {
    return DrawingState(
      paths: paths ?? this.paths,
      currentPathPoints: currentPathPoints ?? this.currentPathPoints,
      selectedTool: selectedTool ?? this.selectedTool,
      penColor: penColor ?? this.penColor,
      penWidth: penWidth ?? this.penWidth,
      eraserWidth: eraserWidth ?? this.eraserWidth,
      eraserPosition: clearEraserPosition
          ? null
          : (eraserPosition ?? this.eraserPosition),
      isCanvasLightMode: isCanvasLightMode ?? this.isCanvasLightMode,
      savedDrawings: savedDrawings ?? this.savedDrawings,
    );
  }

  /// Check if undo is available
  bool get canUndo => paths.isNotEmpty;

  /// Check if eraser is active
  bool get isEraserActive =>
      selectedTool == DrawingTool.eraser && eraserPosition != null;
}
