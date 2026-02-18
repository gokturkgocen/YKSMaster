import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_dialog.dart';
import '../../domain/models/mock_exam.dart'; // Import MockExam
import '../providers/mock_exam_provider.dart';
import '../providers/user_profile_provider.dart';
import 'exam_detail_page.dart';

class DenemePage extends ConsumerWidget {
  const DenemePage({super.key});

  // ── Show Stats Dialog ──
  void _showStatsDialog(BuildContext context, WidgetRef ref, MockExam exam) {
    final theme = ref.read(themeProvider);
    final statsMap = ref
        .read(mockExamProvider.notifier)
        .getExamStatistics(exam.id);

    final tytStats = statsMap.entries
        .where((e) => e.key.startsWith('TYT - '))
        .map((e) => e.value)
        .toList();
    final aytStats = statsMap.entries
        .where((e) => e.key.startsWith('AYT - '))
        .map((e) => e.value)
        .toList();

    GlassDialog.show(
      context: context,
      theme: theme,
      title: Text('${exam.name} Sonuçları'),
      content: SizedBox(
        width: 450,
        height: 400,
        child: StatefulBuilder(
          builder: (context, setState) {
            final PageController controller = PageController();
            int currentPage = 0;

            return Column(
              children: [
                // Custom Tab Indicator
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildDialogTab('TYT', 0, currentPage == 0, theme, () {
                        controller.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }),
                      _buildDialogTab('AYT', 1, currentPage == 1, theme, () {
                        controller.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }),
                    ],
                  ),
                ),

                // PageView for Results
                Expanded(
                  child: PageView(
                    controller: controller,
                    onPageChanged: (index) =>
                        setState(() => currentPage = index),
                    children: [
                      _buildResultsList(tytStats, 'TYT', theme),
                      _buildResultsList(aytStats, 'AYT', theme),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                // Dot Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(currentPage == 0, theme),
                    const SizedBox(width: 8),
                    _buildDot(currentPage == 1, theme),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Tamam',
            style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTab(
    String label,
    int index,
    bool isSelected,
    AppTheme theme,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.accent : theme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active, AppTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? theme.accent
            : theme.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildResultsList(
    List<SubjectStats> stats,
    String type,
    AppTheme theme,
  ) {
    if (stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 48,
              color: theme.textSecondary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              '$type için henüz soru çözülmemiş.',
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final cleanName = stat.subjectName
            .replaceFirst('TYT - ', '')
            .replaceFirst('AYT - ', '');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cleanName,
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${stat.netScore.toStringAsFixed(2)} Net',
                      style: TextStyle(
                        color: theme.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(
                    'Toplam',
                    '${stat.totalQuestions}',
                    theme.textSecondary,
                  ),
                  _buildMiniStat(
                    'Doğru',
                    '${stat.correctAnswers}',
                    const Color(0xFF10B981),
                  ),
                  _buildMiniStat(
                    'Yanlış',
                    '${stat.wrongAnswers}',
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final examState = ref.watch(mockExamProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deneme Sınavları',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Exam list
            Expanded(
              child: examState.exams.isEmpty
                  ? Center(
                      child: Text(
                        'Henüz deneme sınavı yok',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: examState.exams.length,
                      itemBuilder: (context, index) {
                        final exam = examState.exams[index];
                        final progress = examState.getExamProgress(exam.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ExamCard(
                            examId: exam.id,
                            examName: exam.name,
                            examDate: exam.date,
                            progress: progress,
                            questionCount: exam.questions.length,
                            theme: theme,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ExamDetailPage(exam: exam),
                                ),
                              );
                            },
                            onStatsTap: () =>
                                _showStatsDialog(context, ref, exam),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String examId;
  final String examName;
  final DateTime examDate;
  final double progress;
  final int questionCount;
  final AppTheme theme;
  final VoidCallback onTap;
  final VoidCallback onStatsTap; // New callback

  const _ExamCard({
    required this.examId,
    required this.examName,
    required this.examDate,
    required this.progress,
    required this.questionCount,
    required this.theme,
    required this.onTap,
    required this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.transitionDuration,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Exam icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text_fill,
                    color: theme.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Exam info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        examName,
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(examDate),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Button
                IconButton(
                  icon: Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    color: theme.accent,
                  ),
                  onPressed: onStatsTap,
                  tooltip: 'Sonuçları Gör',
                ),

                // Arrow
                Icon(
                  CupertinoIcons.chevron_right,
                  color: theme.textSecondary,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İlerleme',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% • $questionCount soru',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: theme.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
