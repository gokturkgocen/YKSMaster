import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../domain/models/user_model.dart';
import 'auth_provider.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(FirebaseFirestore.instance);
});

final topUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.getTopUsers();
});

final userRankProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  // This part is tricky because we need the user's total points.
  // Ideally we should have a userStatsProvider that gives us the UserModel.
  // For now, let's assume we can get it or return 0 if not ready.
  if (user == null) return 0;

  // We need to fetch the user's current stats to know their score.
  // Or we pass the score as an argument (family provider).
  // Let's simplified by fetching the user doc first.
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  if (!userDoc.exists) return 0;

  final userModel = UserModel.fromMap(userDoc.data()!);
  final totalPoints = (userModel.stats['total_points'] ?? 0).toDouble();

  return repo.getUserRank(user.uid, totalPoints);
});
