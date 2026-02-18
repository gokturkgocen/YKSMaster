import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/mock_exam_provider.dart';
import 'package:yks_vision_tablet/presentation/providers/leaderboard_provider.dart';

import 'settings/settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _selectedTab = 0; // 0: TYT, 1: AYT

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final profile = ref.watch(userProfileProvider);
    final aggregatedStats = ref.watch(aggregatedSubjectStatsProvider);

    // Get expected subjects from branch
    final tytSubjects = profile.branchSubjects
        .where((s) => s.startsWith('TYT - '))
        .toList();
    final aytSubjects = profile.branchSubjects
        .where((s) => s.startsWith('AYT - '))
        .toList();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header with settings - Redesigned
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profil',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.settings,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Profile avatar and info
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.accent.withValues(alpha: 0.2),
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 50,
                  color: theme.accent,
                ),
              ),

              _buildProfileInfo(profile, theme), // Extracted to a method

              const SizedBox(height: 32),

              // Rank & Percentile
              _buildRankInfo(ref, theme),

              const SizedBox(height: 24),

              // Top 10 Leaderboard
              _buildLeaderboard(ref, theme),

              // Subject Statistics with Custom Tabs
              if (profile.selectedBranch != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ders İstatistikleri',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton('TYT', 0, theme),
                          const SizedBox(width: 4),
                          _buildTabButton('AYT', 1, theme),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content based on selection (No fixed height!)
                _selectedTab == 0
                    ? _buildStatsGrid(
                        tytSubjects,
                        aggregatedStats,
                        theme,
                        const Color(0xFF3B82F6),
                      )
                    : _buildStatsGrid(
                        aytSubjects,
                        aggregatedStats,
                        theme,
                        const Color(0xFFF59E0B),
                      ),
                // Extra padding at bottom for scrolling
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index, AppTheme theme) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? theme.accent : theme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    List<String> subjectKeys,
    Map<String, SubjectStats> stats,
    AppTheme theme,
    Color defaultColor,
  ) {
    if (subjectKeys.isEmpty) {
      return Center(
        child: Text(
          'Henüz veri bulunmuyor.',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2, // Very compact cells
      ),
      itemCount: subjectKeys.length,
      itemBuilder: (context, index) {
        final key = subjectKeys[index];
        final displayName = key
            .replaceFirst('TYT - ', '')
            .replaceFirst('AYT - ', '');

        final stat = stats[key] ?? SubjectStats(subjectName: displayName);

        return _SubjectStatCard(
          stats: stat,
          theme: theme,
          color: _getSubjectColor(displayName),
          // We need to pass the displayName explicitly because stat.subjectName
          // might have the prefix if it came from the aggregated map
          displayName: displayName,
          isCompact: true,
        );
      },
    );
  }

  Color _getSubjectColor(String name) {
    if (name.contains('Matematik')) {
      return const Color(0xFF8B5CF6);
    }
    if (name.contains('Fen') || name.contains('Fizik')) {
      return const Color(0xFF10B981);
    }
    if (name.contains('Türk') || name.contains('Edebiyat')) {
      return const Color(0xFF3B82F6);
    }
    if (name.contains('Sosyal') || name.contains('Tarih')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF6B7280);
  }

  Widget _buildProfileInfo(UserProfile profile, AppTheme theme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          profile.nickname ?? profile.name,
          style: TextStyle(
            color: theme.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Branch badge
        if (profile.selectedBranch != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getBranchColor(
                profile.selectedBranch!,
              ).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getBranchColor(profile.selectedBranch!),
                width: 1.5,
              ),
            ),
            child: Text(
              profile.selectedBranch!.displayName,
              style: TextStyle(
                color: _getBranchColor(profile.selectedBranch!),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Color _getBranchColor(Branch branch) {
    switch (branch) {
      case Branch.sayisal:
        return const Color(0xFF3B82F6);
      case Branch.ea:
        return const Color(0xFF8B5CF6);
      case Branch.sozel:
        return const Color(0xFFF59E0B);
    }
  }

  Widget _buildRankInfo(WidgetRef ref, AppTheme theme) {
    final userRank = ref.watch(userRankProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: userRank.when(
        data: (rank) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRankItem(
              'Hayallerindeki Sıra',
              '#$rank',
              theme,
              CupertinoIcons.star_fill,
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.textSecondary.withValues(alpha: 0.2),
            ),
            _buildRankItem(
              'Başarı Yüzden',
              '%${(rank <= 0 ? 0 : (rank * 0.1)).toStringAsFixed(2)}',
              theme,
              CupertinoIcons.flame_fill,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text(
          'Sıralama yüklenemedi',
          style: TextStyle(color: theme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildRankItem(
    String label,
    String value,
    AppTheme theme,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.accent, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: theme.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildLeaderboard(WidgetRef ref, AppTheme theme) {
    final topUsers = ref.watch(topUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En İyiler 🏆',
          style: TextStyle(
            color: theme.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        topUsers.when(
          data: (users) {
            if (users.isEmpty) {
              return Text(
                'Henüz veri yok.',
                style: TextStyle(color: theme.textSecondary),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                final isTop3 = index < 3;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isTop3
                        ? theme.accent.withValues(alpha: 0.1)
                        : theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isTop3
                        ? Border.all(color: theme.accent.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}.',
                        style: TextStyle(
                          color: isTop3 ? theme.accent : theme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.accent.withValues(alpha: 0.2),
                        child: Text(
                          user.nickname.isNotEmpty
                              ? user.nickname[0].toUpperCase()
                              : user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: theme.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user.nickname.isNotEmpty ? user.nickname : user.name,
                          style: TextStyle(
                            color: theme.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${user.stats['total_points'] ?? 0} Puan',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            'Liste yüklenemedi: $e',
            style: TextStyle(color: theme.textSecondary),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Methods & Classes
// -----------------------------------------------------------------------------

IconData _getSubjectIcon(String name) {
  if (name.contains('Türk')) {
    return CupertinoIcons.book_fill;
  }
  if (name.contains('Sosyal') ||
      name.contains('Tarih') ||
      name.contains('Coğrafya')) {
    return CupertinoIcons.globe;
  }
  if (name.contains('Matematik')) {
    return CupertinoIcons.function;
  }
  if (name.contains('Fen') ||
      name.contains('Fizik') ||
      name.contains('Kimya') ||
      name.contains('Biyoloji')) {
    return CupertinoIcons.lab_flask_solid;
  }
  return CupertinoIcons.doc_text_fill;
}

class _SubjectStatCard extends StatelessWidget {
  final SubjectStats stats;
  final AppTheme theme;
  final Color color;
  final String displayName;
  final bool isCompact;

  const _SubjectStatCard({
    required this.stats,
    required this.theme,
    required this.color,
    required this.displayName,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Accent Line (only if not compact)
            if (!isCompact)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.4)],
                  ),
                ),
              ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isCompact ? 6 : 8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getSubjectIcon(stats.subjectName),
                            color: color,
                            size: isCompact ? 16 : 18,
                          ),
                        ),
                        SizedBox(width: isCompact ? 8 : 10),
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              color: theme.text,
                              fontSize: isCompact ? 13 : 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isCompact ? 8 : 16),

                    // Detailed Stats Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          label: 'Toplam',
                          value: '${stats.totalQuestions}',
                          theme: theme,
                          isCompact: isCompact,
                          icon: CupertinoIcons.doc_text,
                        ),
                        _StatItem(
                          label: 'Doğru',
                          value: '${stats.correctAnswers}',
                          theme: theme,
                          isCompact: isCompact,
                          icon: CupertinoIcons.checkmark_alt,
                          valueColor: const Color(0xFF10B981),
                        ),
                        _StatItem(
                          label: 'Yanlış',
                          value: '${stats.wrongAnswers}',
                          theme: theme,
                          isCompact: isCompact,
                          icon: CupertinoIcons.xmark,
                          valueColor: const Color(0xFFEF4444),
                        ),
                        // Net with background
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 8 : 12,
                            vertical: isCompact ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                stats.netScore.toStringAsFixed(1),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCompact ? 16 : 18,
                                ),
                              ),
                              Text(
                                'Net',
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: isCompact ? 10 : 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final AppTheme theme;
  final bool isCompact;
  final IconData? icon;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.theme,
    this.isCompact = false,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Compact column
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: isCompact ? 14 : 16,
            color: valueColor ?? theme.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? theme.text,
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        if (icon == null) ...[
          // Only show label text if no icon, or maybe both? Let's show label below.
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          // If icon is present, still show label? User previously saw "Doğru", "Yanlış" etc.
          // Let's keep it minimal.
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
