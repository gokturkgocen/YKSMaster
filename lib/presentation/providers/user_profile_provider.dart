import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/leaderboard_repository.dart';
import 'auth_provider.dart';
import 'leaderboard_provider.dart';

/// User's selected branch (Sayısal, EA, Sözel)
enum Branch {
  sayisal('Sayısal'),
  ea('Eşit Ağırlık'),
  sozel('Sözel');

  final String displayName;
  const Branch(this.displayName);
}

/// Subject statistics for a specific subject
class SubjectStats {
  final String subjectName;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;

  const SubjectStats({
    required this.subjectName,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
  });

  Map<String, dynamic> toJson() => {
    'subjectName': subjectName,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'wrongAnswers': wrongAnswers,
  };

  factory SubjectStats.fromJson(Map<String, dynamic> json) => SubjectStats(
    subjectName: json['subjectName'] as String,
    totalQuestions: (json['totalQuestions'] as num).toInt(),
    correctAnswers: (json['correctAnswers'] as num).toInt(),
    wrongAnswers: (json['wrongAnswers'] as num).toInt(),
  );

  double get netScore {
    // Net = Doğru - (Yanlış / 4)
    return correctAnswers - (wrongAnswers / 4);
  }

  double get scoreOutOf40 {
    // Normalize to 40 questions
    if (totalQuestions == 0) return 0;
    return (netScore / totalQuestions) * 40;
  }

  SubjectStats copyWith({
    String? subjectName,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
  }) {
    return SubjectStats(
      subjectName: subjectName ?? this.subjectName,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
    );
  }
}

/// User profile model
class UserProfile {
  final String name;
  final String? nickname;
  final Branch? selectedBranch;
  final Map<String, SubjectStats> subjectStats;
  final List<String> solvedQuestionIds;
  final List<String> wrongQuestionIds;

  const UserProfile({
    this.name = 'Kullanıcı',
    this.nickname,
    this.selectedBranch,
    this.subjectStats = const {},
    this.solvedQuestionIds = const [],
    this.wrongQuestionIds = const [],
  });

  UserProfile copyWith({
    String? name,
    String? nickname,
    Branch? selectedBranch,
    Map<String, SubjectStats>? subjectStats,
    List<String>? solvedQuestionIds,
    List<String>? wrongQuestionIds,
  }) {
    return UserProfile(
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      subjectStats: subjectStats ?? this.subjectStats,
      solvedQuestionIds: solvedQuestionIds ?? this.solvedQuestionIds,
      wrongQuestionIds: wrongQuestionIds ?? this.wrongQuestionIds,
    );
  }

  /// Get subjects for the selected branch (both TYT and AYT)
  List<String> get branchSubjects {
    if (selectedBranch == null) return [];

    final tyt = [
      'TYT - Türkçe',
      'TYT - Sosyal Bilimler',
      'TYT - Temel Matematik',
      'TYT - Fen Bilimleri',
    ];

    List<String> ayt = [];
    switch (selectedBranch!) {
      case Branch.sayisal:
        ayt = ['AYT - Matematik', 'AYT - Fen Bilimleri'];
        break;
      case Branch.ea:
        ayt = [
          'AYT - Matematik',
          'AYT - Türk Dili ve Edebiyatı-Sosyal Bilimler-1',
        ];
        break;
      case Branch.sozel:
        ayt = [
          'AYT - Türk Dili ve Edebiyatı-Sosyal Bilimler-1',
          'AYT - Sosyal Bilimler-2',
        ];
        break;
    }

    return [...tyt, ...ayt];
  }

  /// Calculate goal probability based on total questions solved
  /// Logic:
  /// - 0-100 questions: 0.1% per question (reach 10%)
  /// - 100-400 questions: 0.05% per question (reach 25%)
  /// - 400-2400 questions: 0.02% per question (reach 65%)
  /// - 2400+ questions: 0.005% per question (hard to reach 90%)
  /// - Max 99.9% via questions
  /// - Becomes 100% only 1 day before exam or on exam day
  double get totalNet {
    return subjectStats.values.fold(0.0, (sum, stat) => sum + stat.netScore);
  }

  double get goalProbability {
    // Check Date: YKS 2026 (21 June)
    // Note: In a real app, date should be fetched from a server or robust source
    final now = DateTime.now();
    final yks = DateTime(2026, 6, 21);
    final difference = yks.difference(now).inDays;

    // If 1 day left or exam day (or passed, assuming they took it)
    // "sınava 1 gün kala otomatik %100 olsun"
    if (difference <= 1) {
      return 1.0;
    }

    final totalSolved = subjectStats.values.fold<int>(
      0,
      (sum, stat) => sum + stat.totalQuestions,
    );

    double probability = 0.0;

    // Tier 1: 0-100 questions (0.1% each) -> Max 10%
    if (totalSolved <= 100) {
      probability = totalSolved * 0.001;
    } else {
      probability += 0.10;
      int remaining = totalSolved - 100;

      // Tier 2: 100-400 questions (0.05% each) -> Max +15% = 25%
      // 300 questions * 0.0005 = 0.15
      if (remaining <= 300) {
        probability += remaining * 0.0005;
      } else {
        probability += 0.15;
        remaining -= 300;

        // Tier 3: 400-2400 questions (0.02% each) -> Max +40% = 65%
        // 2000 questions * 0.0002 = 0.40
        if (remaining <= 2000) {
          probability += remaining * 0.0002;
        } else {
          probability += 0.40;
          remaining -= 2000;

          // Tier 4: 2400+ questions (0.005% each) -> Hard to reach 90%
          // To get +25% (reach 90%), need 5000 questions
          probability += remaining * 0.00005;
        }
      }
    }

    // Cap at 99.9% normally
    return probability.clamp(0.0, 0.999);
  }

  /// Get TYT specific statistics
  Map<String, SubjectStats> get tytStats {
    final filtered = <String, SubjectStats>{};
    subjectStats.forEach((key, value) {
      if (key.startsWith('TYT - ')) {
        filtered[key.replaceFirst('TYT - ', '')] = value;
      }
    });
    return filtered;
  }

  /// Get AYT specific statistics
  Map<String, SubjectStats> get aytStats {
    final filtered = <String, SubjectStats>{};
    subjectStats.forEach((key, value) {
      if (key.startsWith('AYT - ')) {
        filtered[key.replaceFirst('AYT - ', '')] = value;
      }
    });
    return filtered;
  }

  // Getter for stats identification
}

/// Notifier for user profile state
class UserProfileNotifier extends StateNotifier<UserProfile> {
  final LeaderboardRepository _leaderboardRepo;
  final AuthRepository _authRepo;

  UserProfileNotifier(this._leaderboardRepo, this._authRepo)
    : super(const UserProfile()) {
    _loadProfile();
  }

  static const _keyBranch = 'selected_branch';
  static const _keyName = 'user_name';
  static const _keyNickname = 'user_nickname';
  static const _keyStats = 'subject_stats';
  static const _keySolvedQuestions = 'solved_question_ids';
  static const _keyWrongQuestions = 'wrong_question_ids';

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final branchIndex = prefs.getInt(_keyBranch);
    final name = prefs.getString(_keyName) ?? 'Kullanıcı';
    final nickname = prefs.getString(_keyNickname);
    final solvedQuestions = prefs.getStringList(_keySolvedQuestions) ?? [];
    final wrongQuestions = prefs.getStringList(_keyWrongQuestions) ?? [];

    // Load stats
    Map<String, SubjectStats> stats = {};
    final statsJsonString = prefs.getString(_keyStats);
    if (statsJsonString != null) {
      try {
        final decoded = json.decode(statsJsonString) as Map<String, dynamic>;
        stats = decoded.map(
          (key, value) => MapEntry(
            key,
            SubjectStats.fromJson(value as Map<String, dynamic>),
          ),
        );
      } catch (e) {
        // Handle error
      }
    }

    // If no stats loaded, generate empty stats based on branch (if branch selected)
    if (stats.isEmpty && branchIndex != null) {
      stats = _generateMockStats(Branch.values[branchIndex]);
    }

    state = UserProfile(
      name: name,
      nickname: nickname,
      selectedBranch: branchIndex != null ? Branch.values[branchIndex] : null,
      subjectStats: stats,
      solvedQuestionIds: solvedQuestions,
      wrongQuestionIds: wrongQuestions,
    );

    // Initial sync from Firestore if logged in
    _initialSyncFromFirestore();
  }

  Future<void> _initialSyncFromFirestore() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final remoteProfile = await _leaderboardRepo.getUserProfile(user.uid);
      if (remoteProfile != null) {
        // Simple merge: remote often wins for specific fields
        Branch? remoteBranch;
        // Logic to extract branch from stats or dedicated field if we add it
        // For now, let's assume we store it in Firestore too.

        state = state.copyWith(
          name: remoteProfile.name.isNotEmpty ? remoteProfile.name : state.name,
          nickname: remoteProfile.nickname.isNotEmpty
              ? remoteProfile.nickname
              : state.nickname,
        );
      }
    }
  }

  Future<void> _saveStats(Map<String, SubjectStats> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      stats.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_keyStats, jsonString);
    await prefs.setStringList(_keySolvedQuestions, state.solvedQuestionIds);
    await prefs.setStringList(_keyWrongQuestions, state.wrongQuestionIds);
  }

  Future<void> selectBranch(Branch branch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBranch, branch.index);

    // Reset stats when changing branch? Or keep them?
    final newStats = _generateMockStats(branch);

    state = state.copyWith(selectedBranch: branch, subjectStats: newStats);
    _saveStats(newStats);
    _syncToFirestore();
  }

  Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyNickname,
      name,
    ); // User sets nickname via this currently
    state = state.copyWith(nickname: name);
    _syncToFirestore();
  }

  /// Update statistics for a specific subject
  void updateQuestionStat(String subject, bool isCorrect, String? questionId) {
    if (!state.subjectStats.containsKey(subject)) return;

    final currentStat = state.subjectStats[subject]!;
    final updatedStat = currentStat.copyWith(
      totalQuestions: currentStat.totalQuestions + 1,
      correctAnswers: currentStat.correctAnswers + (isCorrect ? 1 : 0),
      wrongAnswers: currentStat.wrongAnswers + (isCorrect ? 0 : 1),
    );

    final updatedStats = Map<String, SubjectStats>.from(state.subjectStats);
    updatedStats[subject] = updatedStat;

    final updatedSolved = List<String>.from(state.solvedQuestionIds);
    if (questionId != null && !updatedSolved.contains(questionId)) {
      updatedSolved.add(questionId);
    }

    final updatedWrong = List<String>.from(state.wrongQuestionIds);
    if (!isCorrect &&
        questionId != null &&
        !updatedWrong.contains(questionId)) {
      updatedWrong.add(questionId);
    } else if (isCorrect && questionId != null) {
      updatedWrong.remove(questionId);
    }

    state = state.copyWith(
      subjectStats: updatedStats,
      solvedQuestionIds: updatedSolved,
      wrongQuestionIds: updatedWrong,
    );
    _saveStats(updatedStats);
    _syncToFirestore();
  }

  Future<void> _syncToFirestore() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final statsMap = state.subjectStats.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
      // Add total points
      final totalPoints = state.totalNet;

      final payload = {
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? state.name,
        'nickname': state.nickname ?? '',
        'branch': state.selectedBranch?.name,
        'stats': statsMap,
        'total_points': totalPoints,
        'total_correct': state.subjectStats.values.fold(
          0,
          (sum, s) => sum + s.correctAnswers,
        ),
        'solved_question_ids': state.solvedQuestionIds,
        'wrong_question_ids': state.wrongQuestionIds,
      };

      await _leaderboardRepo.updateUserStats(user.uid, payload);
    }
  }

  /// Generate empty statistics for a branch
  Map<String, SubjectStats> _generateMockStats(Branch? branch) {
    if (branch == null) return {};

    final subjects = UserProfile(selectedBranch: branch).branchSubjects;
    return {
      for (var subject in subjects)
        subject: SubjectStats(
          subjectName: subject,
          totalQuestions: 0,
          correctAnswers: 0,
          wrongAnswers: 0,
        ),
    };
  }

  /// Clear user statistics and solved question IDs but keep profile info
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStats);
    await prefs.remove(_keySolvedQuestions);
    await prefs.remove(_keyWrongQuestions);

    // Reset stats in state
    final emptyStats = _generateMockStats(state.selectedBranch);
    state = state.copyWith(
      subjectStats: emptyStats,
      solvedQuestionIds: [],
      wrongQuestionIds: [],
    );
    _syncToFirestore();
  }

  /// Delete account and reset app state
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data

    // Reset state to initial default
    state = const UserProfile();
  }
}

/// Provider for user profile
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
      final authRepo = ref.watch(authRepositoryProvider);
      final leaderboardRepo = ref.watch(leaderboardRepositoryProvider);
      return UserProfileNotifier(leaderboardRepo, authRepo);
    });
