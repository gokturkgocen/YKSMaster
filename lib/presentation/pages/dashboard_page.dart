import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../widgets/countdown_timer.dart';
import '../providers/user_profile_provider.dart';
import '../providers/usage_tracker_provider.dart';
import '../widgets/glass_dialog.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final profile = ref.watch(userProfileProvider);
    final goalProbability = profile.goalProbability;
    final goalPercentage = (goalProbability * 100).toInt();

    // YKS Date: June 21, 2026
    final yksDate = DateTime(2026, 6, 21);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Greeting and Theme Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getGreeting()}, ${profile.nickname ?? profile.name}',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Theme Toggle
                  GestureDetector(
                    onTap: themeNotifier.toggleTheme,
                    child: AnimatedContainer(
                      duration: AppTheme.transitionDuration,
                      curve: AppTheme.transitionCurve,
                      width: 56,
                      height: 32,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.isDark
                            ? const Color(0xFF3D3A36)
                            : const Color(0xFFE5E7EB),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: AppTheme.transitionDuration,
                            curve: AppTheme.transitionCurve,
                            alignment: theme.isDark
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                theme.isDark
                                    ? CupertinoIcons.moon_fill
                                    : CupertinoIcons.sun_max_fill,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Progress Bar Section
              // "Geçme ihtimalin" -> "Hedefine ulaşma ihtimalin"
              Container(
                padding: const EdgeInsets.all(20),
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
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          goalPercentage == 100
                              ? 'Başarılar! Sen Hazırsın 🚀'
                              : 'Hayallerine Yakınlık Seviyen',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '%$goalPercentage', // Dynamic percentage
                          style: TextStyle(
                            color: theme.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 32,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final progress = goalProbability;
                          final barWidth = constraints.maxWidth;
                          // Ensure progress is at least visible if > 0
                          final displayProgress =
                              progress < 0.01 && progress > 0 ? 0.01 : progress;
                          final filledWidth = barWidth * displayProgress;

                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              // Background track
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: theme.isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              // Filled track
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                height: 12,
                                width: filledWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.accent,
                                      theme.accent.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),
                              // Graduation cap at the tip
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                left: filledWidth - 14,
                                top: -12,
                                child: const Text(
                                  '🎓',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Daily Usage Section
              _buildDailyUsageCard(context, ref, theme),

              const SizedBox(height: 32),

              // Countdown Section
              Text(
                'Kalan Süre',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CountdownTimer(
                targetDate: yksDate,
                theme:
                    theme, // Passing theme explicitly if widget requires it or it can watch it itself
              ),

              const SizedBox(height: 32),

              // Categories/Quick Access
              Text(
                'Sınav Kategorileri',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                title: 'Sınav Simülasyonu',
                description:
                    'Gerçek sınavla birebir aynı tasarım ve formatta süreli denemeler',
                progress: '0/2',
                icon: CupertinoIcons.timer,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String description,
    required String progress,
    required IconData icon,
    required AppTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? const Color(0xFF3D3A36)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.0, // 0/2
              minHeight: 6,
              backgroundColor: theme.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyUsageCard(
    BuildContext context,
    WidgetRef ref,
    AppTheme theme,
  ) {
    // Watch usage state
    final usageState = ref.watch(usageTrackerProvider);
    final seconds = usageState.todaySeconds;

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final displaySeconds = seconds % 60;

    final formattedTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    final secondsSmall = displaySeconds.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.accent.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Icon and Label
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.time,
                    color: theme.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Bugünkü Çalışma',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Center: Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formattedTime,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                ':$secondsSmall',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Right: History Button
          IconButton(
            onPressed: () => _showHistoryDialog(context, usageState, theme),
            icon: Icon(
              CupertinoIcons.chart_bar_alt_fill,
              color: theme.textSecondary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'Günaydın';
    if (hour >= 12 && hour < 17) return 'Tünaydın';
    if (hour >= 17 && hour < 22) return 'İyi Akşamlar';
    return 'İyi Geceler';
  }

  void _showHistoryDialog(
    BuildContext context,
    DailyUsageState state,
    AppTheme theme,
  ) {
    GlassDialog.show(
      context: context,
      theme: theme,
      title: const Text('Çalışma Geçmişi'),
      content: state.history.isEmpty
          ? Center(
              child: Text(
                'Henüz çalışma verisi yok.',
                style: TextStyle(color: theme.textSecondary),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: state.history.entries.toList().reversed.map((entry) {
                final dateStr = entry.key;
                final seconds = entry.value;

                // Basic date formatting yyyyMMdd -> DD.MM.YYYY
                String formattedDate = dateStr;
                if (dateStr.length == 8) {
                  formattedDate =
                      '${dateStr.substring(6, 8)}.${dateStr.substring(4, 6)}.${dateStr.substring(0, 4)}';
                }

                final hours = seconds ~/ 3600;
                final minutes = (seconds % 3600) ~/ 60;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.divider.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 18,
                            color: theme.textSecondary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: theme.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${hours}sa ${minutes}dk',
                          style: TextStyle(
                            color: theme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Kapat',
            style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
