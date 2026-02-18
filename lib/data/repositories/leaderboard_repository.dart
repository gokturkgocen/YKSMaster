import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore;

  LeaderboardRepository(this._firestore);

  // Fetch top 10 users ordered by 'stats.total_points' descending
  Future<List<UserModel>> getTopUsers({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('stats.total_points', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      // Handle errors or return empty list
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  // Calculate generic percentile based on total points
  // Note: True percentile calculation on NoSQL often requires aggregation functions
  // or a counter of total users. This is a simplified client-side approximation
  // if we fetch strictly necessary data or use a Cloud Function.
  // For the sake of this task, we will assume we store 'rank' directly in user document
  // updated by a scheduled Cloud Function, or we simulate it here if possible.

  // Real-time rank fetching isn't scalable on client-side for millions of users,
  // but for a few users we can count how many have higher score.
  Future<int> getUserRank(String uid, double totalPoints) async {
    try {
      final countQuery = await _firestore
          .collection('users')
          .where('stats.total_points', isGreaterThan: totalPoints)
          .count()
          .get();

      return countQuery.count! + 1;
    } catch (e) {
      print('Error getting user rank: $e');
      return 0;
    }
  }

  // Fetch user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Update user stats and profile info
  Future<void> updateUserStats(String uid, Map<String, dynamic> data) async {
    // Use set with merge: true to create or update
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}
