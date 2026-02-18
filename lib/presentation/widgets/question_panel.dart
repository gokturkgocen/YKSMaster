import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/question_notifier.dart';
import '../providers/theme_provider.dart';

/// Liquid Glass style question panel with dark mode support
class QuestionPanel extends ConsumerWidget {
  const QuestionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionState = ref.watch(questionProvider);
    final questionNotifier = ref.read(questionProvider.notifier);
    final theme = ref.watch(themeProvider);
    final question = questionState.currentQuestion;

    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.isDark
              ? [const Color(0xFF252422), const Color(0xFF1C1B1A)]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
        ),
      ),
      child: Column(
        children: [
          // Header with question number and subject
          _buildHeader(
            question.subject,
            questionState.currentIndex + 1,
            questionState.totalQuestions,
            theme,
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Text(
                    question.questionText,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: theme.text,
                      height: 1.6,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer options
                  ...List.generate(question.options.length, (index) {
                    return _AnswerOption(
                      label: String.fromCharCode(65 + index),
                      text: question.options[index],
                      isSelected: questionState.selectedAnswer == index,
                      onTap: () => questionNotifier.selectAnswer(index),
                      theme: theme,
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationBar(questionState, questionNotifier, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(String subject, int current, int total, AppTheme theme) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: theme.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: theme.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              // Subject badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.accent.withValues(
                        alpha: theme.isDark ? 0.25 : 0.15,
                      ),
                      theme.accent.withValues(
                        alpha: theme.isDark ? 0.15 : 0.08,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.accent.withValues(
                      alpha: theme.isDark ? 0.4 : 0.2,
                    ),
                  ),
                ),
                child: Text(
                  subject.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.isDark
                        ? const Color(0xFF60A5FA)
                        : theme.accent,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              const Spacer(),

              // Question counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$current / $total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar(
    QuestionState state,
    QuestionNotifier notifier,
    AppTheme theme,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: theme.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              // Previous button
              _NavigationButton(
                icon: Icons.arrow_back_ios_rounded,
                label: 'Önceki',
                isEnabled: state.canGoPrevious,
                onTap: notifier.previousQuestion,
                theme: theme,
              ),

              const Spacer(),

              // Next button
              _NavigationButton(
                icon: Icons.arrow_forward_ios_rounded,
                label: 'Sonraki',
                isEnabled: state.canGoNext,
                isPrimary: true,
                iconAfter: true,
                onTap: notifier.nextQuestion,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual answer option with theme support
class _AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final AppTheme theme;

  const _AnswerOption({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      theme.accent.withValues(alpha: theme.isDark ? 0.2 : 0.12),
                      theme.accent.withValues(
                        alpha: theme.isDark ? 0.12 : 0.06,
                      ),
                    ]
                  : theme.isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.6),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.accent.withValues(alpha: 0.5)
                  : theme.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.accent.withValues(
                        alpha: theme.isDark ? 0.25 : 0.15,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.isDark ? 0.2 : 0.03,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Label circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF007AFF), Color(0xFF0056D6)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : theme.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : theme.isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : theme.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Option text
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? theme.isDark
                              ? const Color(0xFF60A5FA)
                              : theme.accent
                        : theme.text,
                    height: 1.4,
                  ),
                ),
              ),

              // Check icon
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF007AFF), Color(0xFF0056D6)],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation button with theme support
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final bool isPrimary;
  final bool iconAfter;
  final VoidCallback onTap;
  final AppTheme theme;

  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    this.isPrimary = false,
    this.iconAfter = false,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF007AFF), Color(0xFF0056D6)],
                  )
                : null,
            color: isPrimary
                ? null
                : theme.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: theme.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!iconAfter) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isPrimary ? Colors.white : theme.textSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : theme.text,
                ),
              ),
              if (iconAfter) ...[
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 16,
                  color: isPrimary ? Colors.white : theme.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
