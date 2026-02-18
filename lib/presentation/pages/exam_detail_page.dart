import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mock_exam.dart';
import '../providers/theme_provider.dart';
import 'exam_solving_page.dart';

class ExamDetailPage extends ConsumerStatefulWidget {
  final MockExam exam;

  const ExamDetailPage({super.key, required this.exam});

  @override
  ConsumerState<ExamDetailPage> createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends ConsumerState<ExamDetailPage> {
  ExamType selectedType = ExamType.tyt;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final subjects = widget.exam.getSubjectsForType(selectedType);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.chevron_back,
                            color: theme.accent,
                            size: 22,
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
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.exam.name,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 80), // Balance back button
                ],
              ),
            ),

            // TYT/AYT Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'TYT',
                      isSelected: selectedType == ExamType.tyt,
                      theme: theme,
                      onTap: () => setState(() => selectedType = ExamType.tyt),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TabButton(
                      label: 'AYT',
                      isSelected: selectedType == ExamType.ayt,
                      theme: theme,
                      onTap: () => setState(() => selectedType = ExamType.ayt),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subject list
            Expanded(
              child: subjects.isEmpty
                  ? Center(
                      child: Text(
                        '${selectedType.displayName} için soru bulunmuyor',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final questions = widget.exam.getQuestionsBySubject(
                          subject,
                          type: selectedType,
                        );

                        return _SubjectCard(
                          subject: subject,
                          questionCount: questions.length,
                          theme: theme,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExamSolvingPage(
                                  exam: widget.exam,
                                  subject: subject,
                                  statsKey:
                                      '${selectedType.displayName} - $subject',
                                  questions: questions,
                                ),
                              ),
                            );
                          },
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

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final AppTheme theme;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.transitionDuration,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent : theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.accent
                : theme.divider.withValues(alpha: 0.5),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject;
  final int questionCount;
  final AppTheme theme;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.questionCount,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.transitionDuration,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(_getSubjectIcon(subject), color: theme.accent, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$questionCount soru',
                    style: TextStyle(color: theme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: theme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    if (subject.contains('Matematik')) return CupertinoIcons.function;
    if (subject.contains('Fen')) return CupertinoIcons.lab_flask_solid;
    if (subject.contains('Türk')) return CupertinoIcons.book_fill;
    if (subject.contains('Sosyal')) return CupertinoIcons.globe;
    return CupertinoIcons.doc_text_fill;
  }
}
