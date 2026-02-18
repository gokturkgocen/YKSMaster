import 'dart:async';
import 'dart:ui'; // For PointerDeviceKind

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mock_exam.dart';
import '../providers/theme_provider.dart';
import '../providers/drawing_notifier.dart';
import '../providers/drawing_state.dart';
import '../providers/mock_exam_provider.dart';
import '../widgets/drawing_path.dart';
import '../widgets/smooth_drawing_painter.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/pen_settings_popup.dart';
import '../widgets/eraser_cursor.dart';
import '../providers/user_profile_provider.dart';

/// Exam solving screen with question panel and drawing canvas
class ExamSolvingPage extends ConsumerStatefulWidget {
  final MockExam exam;
  final String subject;
  final String? statsKey; // New optional key for differentiated stats
  final List<ExamQuestion> questions;

  const ExamSolvingPage({
    super.key,
    required this.exam,
    required this.subject,
    this.statsKey,
    required this.questions,
  });

  @override
  ConsumerState<ExamSolvingPage> createState() => _ExamSolvingPageState();
}

class _ExamSolvingPageState extends ConsumerState<ExamSolvingPage> {
  int currentQuestionIndex = 0;
  Timer? _timer;
  int _totalSeconds = 0;
  int _currentQuestionSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Load drawings for the first question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.questions.isNotEmpty) {
        ref.read(drawingProvider.notifier).loadPage(widget.questions[0].id);
        _loadTimers();
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveTimers(); // Save on exit
    super.dispose();
  }

  void _loadTimers() {
    final state = ref.read(mockExamProvider);
    _totalSeconds = state.examDurations[widget.exam.id] ?? 0;

    final currentQId = widget.questions[currentQuestionIndex].id;
    _currentQuestionSeconds =
        state.questionDurations[widget.exam.id]?[currentQId] ?? 0;
  }

  void _saveTimers() {
    if (widget.questions.isEmpty) return;

    final currentQId = widget.questions[currentQuestionIndex].id;
    final notifier = ref.read(mockExamProvider.notifier);

    notifier.saveExamDuration(widget.exam.id, _totalSeconds);
    notifier.saveQuestionDuration(
      widget.exam.id,
      currentQId,
      _currentQuestionSeconds,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _totalSeconds++;
          _currentQuestionSeconds++;
        });

        // Auto-save every 10 seconds to prevent data loss on crash
        if (_totalSeconds % 10 == 0) {
          _saveTimers();
        }
      }
    });
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final drawingState = ref.watch(drawingProvider);
    final drawingNotifier = ref.read(drawingProvider.notifier);
    final theme = ref.watch(themeProvider);

    // Watch exam state for changes
    final examState = ref.watch(mockExamProvider);
    final examNotifier = ref.read(mockExamProvider.notifier);

    final currentQuestion = widget.questions[currentQuestionIndex];
    // Get answer directly from state or via notifier (since we watch state, this will update)
    final selectedAnswer =
        examState.examAnswers[widget.exam.id]?[currentQuestion.id];

    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      color: theme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Back button bar
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: theme.surface,
                    title: Text(
                      'Sınavdan Çık?',
                      style: TextStyle(color: theme.text),
                    ),
                    content: Text(
                      'Sınavdan çıkmak istediğine emin misin? İlerlemen kaydedilecek.',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Stay
                        child: Text(
                          'Hayır',
                          style: TextStyle(color: theme.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Save current drawing before leaving
                          if (widget.questions.isNotEmpty) {
                            ref
                                .read(drawingProvider.notifier)
                                .savePage(
                                  widget.questions[currentQuestionIndex].id,
                                );
                          }
                          Navigator.pop(context); // Close dialog
                          Navigator.of(context).pop(); // Close page
                        },
                        child: Text(
                          'Evet',
                          style: TextStyle(
                            color: theme.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppTheme.transitionDuration,
                curve: AppTheme.transitionCurve,
                height: 48,
                color: theme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Changed mainAxisSize to default (max) to expand
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
                    // Timer Display
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            size: 14,
                            color: theme.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(_totalSeconds),
                            style: TextStyle(
                              color: theme.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(), // Balance the layout (roughly) or keep it right aligned?
                    // Let's remove the second spacer to keep it center-right or just right aligned.
                    // Actually, let's keep it right aligned before the empty space.
                  ],
                ),
              ),
            ),

            // Toolbar
            DrawingToolbar(
              selectedTool: drawingState.selectedTool,
              onPenSelected: () {
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
              onPointerSelected: () =>
                  drawingNotifier.changeTool(DrawingTool.pointer),
              onEraserSelected: () =>
                  drawingNotifier.changeTool(DrawingTool.eraser),
              onLassoSelected: () =>
                  drawingNotifier.changeTool(DrawingTool.lasso),
              onClearAll: drawingNotifier.clearAll,
              onUndo: drawingNotifier.undo,
              canUndo: drawingState.canUndo,
            ),

            // Content Area with Stack
            Expanded(
              child: Stack(
                children: [
                  // 1. Underlying Content (Questions)
                  // Full width Question Panel
                  Row(
                    children: [
                      // Question Panel - Takes full width or split?
                      // User wants to mark anywhere.
                      // Let's keep the split view visual but allow drawing over all of it.
                      Expanded(
                        flex: 1,
                        child: _QuestionPanel(
                          question: currentQuestion,
                          questionNumber: currentQuestionIndex + 1,
                          totalQuestions: widget.questions.length,
                          selectedAnswer: selectedAnswer,
                          onAnswerSelected: (answer) {
                            // Check if already answered
                            final oldAnswer = examNotifier.getAnswer(
                              widget.exam.id,
                              currentQuestion.id,
                            );

                            examNotifier.saveAnswer(
                              widget.exam.id,
                              currentQuestion.id,
                              answer,
                            );

                            if (oldAnswer == null) {
                              final userNotifier = ref.read(
                                userProfileProvider.notifier,
                              );
                              final isCorrect =
                                  currentQuestion.correctAnswer == answer;

                              // Use specific stats key if provided (e.g. TYT - Matematik)
                              // otherwise fallback to question subject
                              userNotifier.updateQuestionStat(
                                widget.statsKey ?? currentQuestion.subject,
                                isCorrect,
                                currentQuestion.id,
                              );
                            }
                          },
                          onPrevious: currentQuestionIndex > 0
                              ? () {
                                  // Save current page state
                                  final currentId =
                                      widget.questions[currentQuestionIndex].id;
                                  ref
                                      .read(drawingProvider.notifier)
                                      .savePage(currentId);
                                  _saveTimers(); // Save timers

                                  setState(() {
                                    currentQuestionIndex--;
                                    _loadTimers(); // Load timers for new question
                                  });

                                  // Load new page state
                                  final prevId =
                                      widget.questions[currentQuestionIndex].id;
                                  ref
                                      .read(drawingProvider.notifier)
                                      .loadPage(prevId);
                                }
                              : null,
                          onNext:
                              currentQuestionIndex < widget.questions.length - 1
                              ? () {
                                  // Save current page state
                                  final currentId =
                                      widget.questions[currentQuestionIndex].id;
                                  ref
                                      .read(drawingProvider.notifier)
                                      .savePage(currentId);
                                  _saveTimers(); // Save timers

                                  setState(() {
                                    currentQuestionIndex++;
                                    _loadTimers(); // Load timers for new question
                                  });

                                  // Load new page state
                                  final nextId =
                                      widget.questions[currentQuestionIndex].id;
                                  ref
                                      .read(drawingProvider.notifier)
                                      .loadPage(nextId);
                                }
                              : null,
                          theme: theme,
                        ),
                      ),

                      // Divider
                      Container(width: 1, color: theme.divider),

                      // Right side blank or notes area?
                      // Originally it was the canvas. Now the canvas is OVER everything.
                      // So the right side can be just a background for notes.
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
                  // Covers the entire area
                  Positioned.fill(
                    child: IgnorePointer(
                      // Ignore touches if using Pointer tool, so buttons work
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
                  // Canvas mode toggle (moved here to be clickable)
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

  Widget _buildDrawingCanvas(
    WidgetRef ref,
    DrawingState state,
    DrawingNotifier notifier,
    AppTheme theme,
  ) {
    // Combine existing paths with the current stroke being drawn
    final allPaths = List<DrawingPath>.from(state.paths);

    if (state.currentPathPoints.isNotEmpty &&
        state.selectedTool == DrawingTool.pen) {
      allPaths.add(
        DrawingPath(
          points: List<Offset>.from(state.currentPathPoints),
          color: state.penColor,
          strokeWidth: state.penWidth,
          tool: state.selectedTool,
        ),
      );
    }

    // Determine correct show condition:
    // Only if active AND valid position AND (pen is down OR user wants to see it).
    // Reverting to: Always show if active and position known, relying on correct updates.
    final bool showEraser =
        state.isEraserActive &&
        state.eraserPosition != null &&
        state.eraserPosition != Offset.zero;

    return Stack(
      children: [
        Listener(
          // HitTestBehavior.translucent is key for "Touch Through".
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) => _handlePointerDown(event, state, notifier),
          onPointerMove: (event) => _handlePointerMove(event, state, notifier),
          onPointerUp: (event) => _handlePointerUp(event, state, notifier),
          onPointerCancel: (event) => _handlePointerUp(null, state, notifier),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            // Colors.transparent is critical for full-area hit testing.
            color: Colors.transparent,
            child: CustomPaint(
              painter: SmoothDrawingPainter(paths: allPaths),
              child: Container(),
            ),
          ),
        ),

        // Eraser cursor overlay
        // EraserCursor returns a Positioned widget, so it must be a direct child of Stack.
        // It handles IgnorePointer internally.
        if (showEraser)
          EraserCursor(
            position: state.eraserPosition!,
            size: state.eraserWidth,
            isVisible: true,
          ),
      ],
    );
  }

  bool _isStylus(PointerEvent event) {
    return event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus ||
        event.kind == PointerDeviceKind.mouse;
  }

  void _handlePointerDown(
    PointerDownEvent event,
    DrawingState state,
    DrawingNotifier notifier,
  ) {
    // 1. Check if it's a Stylus
    if (!_isStylus(event)) return;

    // 2. Handle Tool Actions
    if (state.selectedTool == DrawingTool.eraser) {
      notifier.updateEraserPosition(event.localPosition);
      notifier.eraseStrokeAtPoint(event.localPosition);
    } else if (state.selectedTool == DrawingTool.pen) {
      notifier.startStroke(event.localPosition);
    }
  }

  void _handlePointerMove(
    PointerMoveEvent event,
    DrawingState state,
    DrawingNotifier notifier,
  ) {
    // Always track eraser position if it is stylus/mouse, even if not down (hover)
    if (_isStylus(event)) {
      if (state.selectedTool == DrawingTool.eraser) {
        notifier.updateEraserPosition(event.localPosition);
      }
    }

    // Actual Drawing/Erasing only happens when DOWN
    if (!event.down) return;
    if (!_isStylus(event)) return;

    if (state.selectedTool == DrawingTool.eraser) {
      // Logic handled above for position, just erase here
      notifier.eraseStrokeAtPoint(event.localPosition);
    } else if (state.selectedTool == DrawingTool.pen &&
        state.currentPathPoints.isNotEmpty) {
      notifier.updateStroke(event.localPosition);
    }
  }

  void _handlePointerUp(
    PointerUpEvent? event,
    DrawingState state,
    DrawingNotifier notifier,
  ) {
    if (state.selectedTool == DrawingTool.pen &&
        state.currentPathPoints.isNotEmpty) {
      notifier.endStroke();
    }
    // Do NOT clear eraser position on Up
  }
}

/// Question panel widget
class _QuestionPanel extends StatelessWidget {
  final ExamQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final AppTheme theme;

  const _QuestionPanel({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      color: theme.surface,
      child: Column(
        children: [
          // Question header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soru $questionNumber / $totalQuestions',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.subject,
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.questionText,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(question.options.length, (index) {
                    final optionLabel = String.fromCharCode(
                      65 + index,
                    ); // A, B, C, D
                    final isSelected = selectedAnswer == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => onAnswerSelected(index),
                        // Critical for receiving taps even if something translucent is above
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.accent.withValues(alpha: 0.1)
                                : theme.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.accent
                                  : theme.divider.withValues(alpha: 0.5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.accent
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.accent
                                        : theme.textSecondary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    optionLabel,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : theme.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: TextStyle(
                                    color: theme.text,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    label: 'Önceki',
                    icon: CupertinoIcons.chevron_left,
                    onTap: onPrevious,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _NavButton(
                    label: 'Sonraki',
                    icon: CupertinoIcons.chevron_right,
                    iconRight: true,
                    onTap: onNext,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconRight;
  final VoidCallback? onTap;
  final AppTheme theme;

  const _NavButton({
    required this.label,
    required this.icon,
    this.iconRight = false,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: onTap != null ? theme.accent : theme.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!iconRight) Icon(icon, color: Colors.white, size: 18),
            if (!iconRight) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: onTap != null ? Colors.white : theme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (iconRight) const SizedBox(width: 8),
            if (iconRight) Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Canvas mode toggle widget (reused from HomeView)
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
