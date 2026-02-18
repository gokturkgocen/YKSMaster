import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/user_profile_provider.dart';
import '../../domain/models/user_model.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final leaderboardState = ref.watch(topUsersProvider);
    final userRankState = ref.watch(userRankProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & My Rank
              _buildHeader(userProfile, userRankState, theme),
              const SizedBox(height: 40),

              // Leaderboard Title
              Text(
                'Sıralama (En İyi 10)',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Leaderboard List
              Expanded(
                child: leaderboardState.when(
                  data: (users) => _buildUserList(users, userProfile, theme),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'Hata: $e',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    UserProfile profile,
    AsyncValue<int> rankState,
    AppTheme theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harika Gidiyorsun, ${profile.nickname ?? profile.name}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bugünkü her soru seni hayallerindeki üniversiteye bir adım daha yaklaştırıyor. 🚀',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          _buildStatCard(
            'Hayallerine Yakınlık',
            '%${(profile.goalProbability * 100).toStringAsFixed(1)}',
            CupertinoIcons.sparkles,
          ),
          const SizedBox(width: 16),
          rankState.when(
            data: (rank) => _buildStatCard(
              'Sıralaman',
              rank > 0 ? '#$rank' : '---',
              CupertinoIcons.graph_square_fill,
            ),
            loading: () => _buildStatCard(
              'Sıralaman',
              '...',
              CupertinoIcons.graph_square_fill,
            ),
            error: (_, __) => _buildStatCard(
              'Sıralaman',
              '!',
              CupertinoIcons.graph_square_fill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(
    List<UserModel> users,
    UserProfile currentUser,
    AppTheme theme,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'Henüz veri yok',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        final isMe =
            user.id != '' &&
            user.nickname == currentUser.nickname; // Rough check

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMe ? theme.accent.withValues(alpha: 0.1) : theme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isMe ? theme.accent : theme.divider.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Rank Number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(index, theme),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // User Avatar/Initial
              CircleAvatar(
                backgroundColor: theme.accent.withValues(alpha: 0.2),
                child: Text(
                  (user.nickname.isNotEmpty ? user.nickname : user.name)[0]
                      .toUpperCase(),
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name & Branch
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname.isNotEmpty ? user.nickname : user.name,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.branch ?? 'AYT Henüz Seçilmedi',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Points
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    user.stats['total_points']?.toStringAsFixed(1) ?? '0.0',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Net Puan',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int index, AppTheme theme) {
    if (index == 0) return const Color(0xFFFFD700); // Gold
    if (index == 1) return const Color(0xFFC0C0C0); // Silver
    if (index == 2) return const Color(0xFFCD7F32); // Bronze
    return theme.isDark ? Colors.white24 : Colors.grey[400]!;
  }
}
