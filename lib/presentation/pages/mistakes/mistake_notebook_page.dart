import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/mistake_provider.dart';
import '../../../domain/models/mock_exam.dart';
import '../exam_solving_page.dart';

class MistakeNotebookPage extends ConsumerWidget {
  const MistakeNotebookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mistakesAsync = ref.watch(mistakeQuestionsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Yanlış Defterim',
          style: TextStyle(
            color: theme.text,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: mistakesAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return _buildEmptyState(theme);
          }
          return _buildMistakeList(context, questions, theme, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Hata: $err', style: TextStyle(color: theme.text)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.checkmark_seal_fill,
            size: 80,
            color: theme.accent.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            'Harikasın! 👋',
            style: TextStyle(
              color: theme.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz yanlış yaptığın bir soru yok.\nBöyle devam et!',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakeList(
    BuildContext context,
    List<dynamic> questions,
    AppTheme theme,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(questions.length, theme),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return _buildMistakeCard(context, q, theme, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(int count, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.info_circle_fill, color: theme.accent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Burada yaptığın yanlışları analiz edip tekrar çözebilirsin. Doğru çözdüğün sorular defterden otomatik olarak kalkar. 💪',
              style: TextStyle(color: theme.text, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakeCard(
    BuildContext context,
    ExamQuestion q,
    AppTheme theme,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () {
        // Find existing exam or mock one for navigation
        // For simplicity, we navigate to solving page with just this question
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamSolvingPage(
              exam: _getDummyExam(q),
              subject: q.subject,
              questions: [q],
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.accent.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                q.subject,
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_search,
                      size: 40,
                      color: theme.textSecondary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Soru #${q.id}',
                      style: TextStyle(
                        color: theme.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Yanlış Çözüldü',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.isDark ? Colors.white12 : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Text(
                  'Şimdi Analiz Et',
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to create a dummy exam object for navigation
  MockExam _getDummyExam(ExamQuestion q) {
    final examId = q.metadata?['examId'] ?? 'mistake_analysis';
    return MockExam(
      id: examId,
      name: 'Hızlı Analiz',
      date: DateTime.now(),
      questions: [q],
    );
  }
}
