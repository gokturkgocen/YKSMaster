import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drawing_notifier.dart';
import '../providers/drawing_state.dart';
import '../providers/theme_provider.dart';
import '../widgets/drawing_path.dart';
import '../widgets/smooth_drawing_painter.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/pen_settings_popup.dart';
import '../widgets/eraser_cursor.dart';
import '../widgets/question_panel.dart';

import 'package:flutter/cupertino.dart';

/// Goodnotes 6 inspired HomeView with iOS 26 Liquid Glass aesthetics
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingProvider);
    final drawingNotifier = ref.read(drawingProvider.notifier);
    final theme = ref.watch(themeProvider);
    final canPop = Navigator.of(context).canPop();

    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      color: theme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Back button bar (only when navigated via push)
            if (canPop)
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: AppTheme.transitionDuration,
                  curve: AppTheme.transitionCurve,
                  height: 48,
                  color: theme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Icon(
                          CupertinoIcons.chevron_back,
                          color: theme.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Geri',
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

            // Toolbar
            _buildToolbar(context, drawingState, drawingNotifier),

            // Content Area with Stack
            Expanded(
              child: Stack(
                children: [
                  // 1. Underlying Content
                  Row(
                    children: [
                      // Left Panel - Question Area
                      const Expanded(flex: 1, child: QuestionPanel()),

                      // Divider
                      Container(width: 1, color: theme.divider),

                      // Right Panel - Notes Background
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: drawingState.isCanvasLightMode
                              ? AppTheme.lightCanvasBackground
                              : AppTheme.darkCanvasBackground,
                        ),
                      ),
                    ],
                  ),

                  // 2. Overlay Drawing Canvas
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring:
                          drawingState.selectedTool == DrawingTool.pointer,
                      child: _buildDrawingCanvas(
                        ref,
                        drawingState,
                        drawingNotifier,
                        theme,
                      ),
                    ),
                  ),

                  // Canvas mode toggle (top-right corner)
                  // Moved here to be on top of everything
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _CanvasModeToggle(
                      isLightMode: drawingState.isCanvasLightMode,
                      onToggle: drawingNotifier.toggleCanvasLightMode,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toolbar with pen settings popup trigger
  Widget _buildToolbar(
    BuildContext context,
    DrawingState drawingState,
    DrawingNotifier drawingNotifier,
  ) {
    return DrawingToolbar(
      selectedTool: drawingState.selectedTool,
      onPenSelected: () {
        // If already on pen, show settings popup
        if (drawingState.selectedTool == DrawingTool.pen) {
          PenSettingsPopup.show(
            context: context,
            currentColor: drawingState.penColor,
            currentWidth: drawingState.penWidth,
            onColorChanged: drawingNotifier.changePenColor,
            onWidthChanged: drawingNotifier.changePenWidth,
          );
        } else {
          drawingNotifier.changeTool(DrawingTool.pen);
        }
      },
      onPointerSelected: () => drawingNotifier.changeTool(DrawingTool.pointer),
      onEraserSelected: () => drawingNotifier.changeTool(DrawingTool.eraser),
      onLassoSelected: () => drawingNotifier.changeTool(DrawingTool.lasso),
      onClearAll: drawingNotifier.clearAll,
      onUndo: drawingNotifier.undo,
      canUndo: drawingState.canUndo,
    );
  }

  /// Right panel with drawing canvas and eraser cursor overlay
  Widget _buildDrawingCanvas(
    WidgetRef ref,
    DrawingState drawingState,
    DrawingNotifier drawingNotifier,
    AppTheme theme,
  ) {
    // Combine completed paths with current stroke for live preview
    final List<DrawingPath> allPaths = List<DrawingPath>.from(
      drawingState.paths,
    );

    // Add current stroke if there are points (only for pen mode)
    if (drawingState.currentPathPoints.isNotEmpty &&
        drawingState.selectedTool == DrawingTool.pen) {
      allPaths.add(
        DrawingPath(
          points: List<Offset>.from(drawingState.currentPathPoints),
          color: drawingState.penColor,
          strokeWidth: drawingState.penWidth,
          tool: drawingState.selectedTool,
        ),
      );
    }

    // Canvas is transparent here because background color is handled in the main stack
    return RepaintBoundary(
      child: Stack(
        children: [
          // Drawing canvas
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) =>
                  _handlePointerDown(event, drawingState, drawingNotifier),
              onPointerMove: (event) =>
                  _handlePointerMove(event, drawingState, drawingNotifier),
              onPointerUp: (event) =>
                  _handlePointerUp(drawingState, drawingNotifier),
              child: AnimatedContainer(
                duration: AppTheme.transitionDuration,
                curve: AppTheme.transitionCurve,
                color: Colors.transparent, // Transparent for overlay
                child: CustomPaint(
                  painter: SmoothDrawingPainter(paths: allPaths),
                  isComplex: true,
                  willChange: true,
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // Eraser cursor overlay
          if (drawingState.isEraserActive)
            EraserCursor(
              position: drawingState.eraserPosition!,
              size: drawingState.eraserWidth,
              isVisible: true,
            ),
        ],
      ),
    );
  }

  /// Handle pointer down based on selected tool
  void _handlePointerDown(
    PointerDownEvent event,
    DrawingState state,
    DrawingNotifier notifier,
  ) {
    if (state.selectedTool == DrawingTool.eraser) {
      notifier.eraseStrokeAtPoint(event.localPosition);
    } else if (state.selectedTool == DrawingTool.pen) {
      notifier.startStroke(event.localPosition);
    }
  }

  /// Handle pointer move based on selected tool
  void _handlePointerMove(
    PointerMoveEvent event,
    DrawingState state,
    DrawingNotifier notifier,
  ) {
    if (state.selectedTool == DrawingTool.eraser) {
      notifier.eraseStrokeAtPoint(event.localPosition);
    } else if (state.selectedTool == DrawingTool.pen) {
      notifier.updateStroke(event.localPosition);
    }
  }

  /// Handle pointer up
  void _handlePointerUp(DrawingState state, DrawingNotifier notifier) {
    if (state.selectedTool == DrawingTool.pen) {
      notifier.endStroke();
    } else if (state.selectedTool == DrawingTool.eraser) {
      notifier.clearEraserPosition();
    }
  }
}

/// Small toggle switch for canvas background mode (light/dark)
class _CanvasModeToggle extends StatelessWidget {
  final bool isLightMode;
  final VoidCallback onToggle;
  final AppTheme theme;

  const _CanvasModeToggle({
    required this.isLightMode,
    required this.onToggle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isLightMode ? 'Koyu Tuval' : 'Açık Tuval',
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: AppTheme.transitionDuration,
          curve: AppTheme.transitionCurve,
          width: 56,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isLightMode
                ? const Color(0xFFE5E7EB)
                : const Color(0xFF3D3A36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AppTheme.transitionDuration,
                curve: AppTheme.transitionCurve,
                alignment: isLightMode
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    isLightMode ? Icons.wb_sunny : Icons.nightlight_round,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
