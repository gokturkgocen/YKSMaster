import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/mock_exam_provider.dart';
import 'package:yks_vision_tablet/presentation/providers/question_provider.dart';
import '../../domain/models/mock_exam.dart';
import '../providers/user_profile_provider.dart';
import 'exam_solving_page.dart';
import '../widgets/glass_dialog.dart';

/// Test tab – horizontally split into TYT (left) and AYT (right).
/// TYT shows subjects directly; AYT shows sub-categories first (EA / Sayısal / Sözel),
/// then expands to reveal subjects.
class TestPage extends ConsumerStatefulWidget {
  const TestPage({super.key});

  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  // Track which AYT category is expanded (null = none)
  String? _expandedAytCategory;

  // ── TYT subjects ──
  static const List<_Subject> _tytSubjects = [
    _Subject('Türkçe', CupertinoIcons.textformat, Color(0xFF3B82F6)),
    _Subject('Sosyal Bilimler', CupertinoIcons.globe, Color(0xFFF59E0B)),
    _Subject('Temel Matematik', CupertinoIcons.function, Color(0xFF8B5CF6)),
    _Subject('Fen Bilimleri', CupertinoIcons.lab_flask, Color(0xFF22C55E)),
  ];

  // ── AYT categories with sub-subjects ──
  static const Map<String, _AytCategory> _aytCategories = {
    'Eşit Ağırlık': _AytCategory(
      icon: CupertinoIcons.equal_square,
      color: Color(0xFF6366F1),
      subjects: [
        _Subject('Matematik', CupertinoIcons.function, Color(0xFF8B5CF6)),
        _Subject(
          'Türk Dili ve Edebiyatı-Sosyal Bilimler-1',
          CupertinoIcons.book,
          Color(0xFF3B82F6),
        ),
      ],
    ),
    'Sayısal': _AytCategory(
      icon: CupertinoIcons.sum,
      color: Color(0xFF0EA5E9),
      subjects: [
        _Subject('Matematik', CupertinoIcons.function, Color(0xFF8B5CF6)),
        _Subject('Fen Bilimleri', CupertinoIcons.lab_flask, Color(0xFF22C55E)),
      ],
    ),
    'Sözel': _AytCategory(
      icon: CupertinoIcons.book_fill,
      color: Color(0xFFF97316),
      subjects: [
        _Subject(
          'Türk Dili ve Edebiyatı-Sosyal Bilimler-1',
          CupertinoIcons.book,
          Color(0xFF3B82F6),
        ),
        _Subject('Sosyal Bilimler-2', CupertinoIcons.globe, Color(0xFFF59E0B)),
      ],
    ),
  };

  // ── Standard question counts for normalization ──
  static const Map<String, int> _standardQuestionCounts = {
    'TYT - Türkçe': 40,
    'TYT - Sosyal Bilimler': 20,
    'TYT - Temel Matematik': 40,
    'TYT - Fen Bilimleri': 20,
    'AYT - Matematik': 40,
    'AYT - Fen Bilimleri': 40,
    'AYT - Türk Dili ve Edebiyatı-Sosyal Bilimler-1': 40,
    'AYT - Sosyal Bilimler-2': 40,
  };

  // ── Navigate to question screen ──
  Future<void> _openSubject(String examTypeStr, String subjectName) async {
    // Determine exam type enum
    final type = examTypeStr == 'TYT' ? ExamType.tyt : ExamType.ayt;
    final statsKey = '$examTypeStr - $subjectName';

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(questionRepositoryProvider);
      final questions = await repo.getQuestions(type, subjectName);

      final profile = ref.read(userProfileProvider);
      final solvedIds = profile.solvedQuestionIds;
      final theme = ref.read(themeProvider);

      // Filter out already solved questions
      final filteredQuestions = questions
          .where((q) => !solvedIds.contains(q.id))
          .toList();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (questions.isNotEmpty && filteredQuestions.isEmpty) {
        // Fun message when all questions are solved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.accent,
            content: Row(
              children: [
                const Icon(CupertinoIcons.rocket_fill, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Yuh tüm sorularımızı çözdün! Hızına biz bile yetişemiyoruz 🚀🔥',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (filteredQuestions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444), // Error red
            content: Text(
              '$subjectName için bulutta soru bulunamadı. Lütfen internet bağlantınızı kontrol edin veya yeni soruların eklenmesini bekleyin.',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      // Generate a practice exam on the fly with filtered questions
      final practiceExam = MockExam(
        id: 'practice_${DateTime.now().millisecondsSinceEpoch}',
        name: '$subjectName Testi',
        date: DateTime.now(),
        questions: filteredQuestions,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExamSolvingPage(
            exam: practiceExam,
            subject: subjectName,
            statsKey: statsKey,
            questions: practiceExam.questions,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
      }
    }
  }

  // ── Show Stats Dialog ──
  void _showStatsDialog(String statsKey, String subjectName) {
    final aggregatedStats = ref.read(aggregatedSubjectStatsProvider);
    final stats = aggregatedStats[statsKey];
    final theme = ref.read(themeProvider);

    // Default values if no stats yet
    final total = stats?.totalQuestions ?? 0;
    final correct = stats?.correctAnswers ?? 0;
    final wrong = stats?.wrongAnswers ?? 0;
    final net = stats?.netScore ?? 0.0;

    // Normalization
    final standardCount = _standardQuestionCounts[statsKey] ?? 40;
    final normalizedNet = total > 0 ? (net / total) * standardCount : 0.0;

    GlassDialog.show(
      context: context,
      theme: theme,
      accentColor: _getSubjectColor(subjectName),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSubjectColor(subjectName).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getSubjectIcon(subjectName),
              color: _getSubjectColor(subjectName),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(subjectName),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Net Score Highlight
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.glassBorder),
            ),
            child: Column(
              children: [
                Text(
                  normalizedNet.toStringAsFixed(2),
                  style: TextStyle(
                    color: _getSubjectColor(subjectName),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  '$standardCount Soruda Tahmini Net',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Detail Stats
          _buildGlassStatRow(
            'Toplam Soru',
            '$total',
            CupertinoIcons.doc_text,
            theme.text,
            theme,
          ),
          const SizedBox(height: 12),
          _buildGlassStatRow(
            'Doğru Sayısı',
            '$correct',
            CupertinoIcons.checkmark_circle,
            const Color(0xFF10B981),
            theme,
          ),
          const SizedBox(height: 12),
          _buildGlassStatRow(
            'Yanlış Sayısı',
            '$wrong',
            CupertinoIcons.xmark_circle,
            const Color(0xFFEF4444),
            theme,
          ),
          const SizedBox(height: 12),
          _buildGlassStatRow(
            'Gerçek Net',
            net.toStringAsFixed(2),
            CupertinoIcons.chart_bar,
            theme.accent,
            theme,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Tamam',
            style: TextStyle(
              color: _getSubjectColor(subjectName),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
    AppTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String name) {
    if (name.contains('Türk')) {
      return const Color(0xFF3B82F6);
    }
    if (name.contains('Sosyal') || name.contains('Tarih')) {
      return const Color(0xFFF59E0B);
    }
    if (name.contains('Matematik')) {
      return const Color(0xFF8B5CF6);
    }
    if (name.contains('Fen')) {
      return const Color(0xFF22C55E);
    }
    return const Color(0xFF6B7280);
  }

  IconData _getSubjectIcon(String name) {
    if (name.contains('Türk')) {
      return CupertinoIcons.book_fill;
    }
    if (name.contains('Sosyal') || name.contains('Tarih')) {
      return CupertinoIcons.globe;
    }
    if (name.contains('Matematik')) {
      return CupertinoIcons.function;
    }
    if (name.contains('Fen')) {
      return CupertinoIcons.lab_flask_solid;
    }
    return CupertinoIcons.doc_text_fill;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Title bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Test Çöz',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // ── Two-column body ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    // ── LEFT: TYT ──
                    Expanded(child: _buildTytPanel(theme)),
                    const SizedBox(width: 16),
                    // ── RIGHT: AYT ──
                    Expanded(child: _buildAytPanel(theme)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  //  TYT Panel
  // ═════════════════════════════════════════════════════════════
  Widget _buildTytPanel(AppTheme theme) {
    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    CupertinoIcons.doc_text_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TYT',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Temel Yeterlilik Testi',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: theme.divider.withValues(alpha: 0.5), height: 24),
          // Subject list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _tytSubjects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _buildSubjectTile(
                _tytSubjects[i],
                theme,
                statsKey: 'TYT - ${_tytSubjects[i].name}',
                onTap: () => _openSubject('TYT', _tytSubjects[i].name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  //  AYT Panel
  // ═════════════════════════════════════════════════════════════
  Widget _buildAytPanel(AppTheme theme) {
    return AnimatedContainer(
      duration: AppTheme.transitionDuration,
      curve: AppTheme.transitionCurve,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AYT',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Alan Yeterlilik Testi',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: theme.divider.withValues(alpha: 0.5), height: 24),
          // Category list with expandable subjects
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: _aytCategories.entries.map((entry) {
                final catName = entry.key;
                final cat = entry.value;
                final isExpanded = _expandedAytCategory == catName;
                return _buildAytCategoryTile(catName, cat, isExpanded, theme);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  //  Reusable subject tile
  // ═════════════════════════════════════════════════════════════
  Widget _buildSubjectTile(
    _Subject subject,
    AppTheme theme, {
    required VoidCallback onTap,
    required String statsKey,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.divider.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(subject.icon, color: subject.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  subject.name,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Stats button
              IconButton(
                icon: Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  color: theme.accent.withValues(alpha: 0.7),
                  size: 20,
                ),
                onPressed: () => _showStatsDialog(statsKey, subject.name),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Icon(
                CupertinoIcons.chevron_right,
                color: theme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  //  AYT expandable category tile
  // ═════════════════════════════════════════════════════════════
  Widget _buildAytCategoryTile(
    String name,
    _AytCategory cat,
    bool isExpanded,
    AppTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isExpanded
              ? cat.color.withValues(alpha: theme.isDark ? 0.1 : 0.06)
              : theme.isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? cat.color.withValues(alpha: 0.4)
                : theme.divider.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Category header (tap to expand / collapse)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expandedAytCategory = isExpanded ? null : name;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          color: isExpanded ? cat.color : theme.textSecondary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Expanded subject list
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: cat.subjects.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildSubjectTile(
                        s,
                        theme,
                        statsKey: 'AYT - ${s.name}',
                        onTap: () => _openSubject(
                          'AYT',
                          s.name,
                        ), // Removed extra wrapper
                      ),
                    );
                  }).toList(),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  Data classes
// ═════════════════════════════════════════════════════════════
class _Subject {
  final String name;
  final IconData icon;
  final Color color;
  const _Subject(this.name, this.icon, this.color);
}

class _AytCategory {
  final IconData icon;
  final Color color;
  final List<_Subject> subjects;
  const _AytCategory({
    required this.icon,
    required this.color,
    required this.subjects,
  });
}
