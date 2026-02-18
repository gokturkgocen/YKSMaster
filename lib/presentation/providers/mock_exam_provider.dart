import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/mock_exam.dart';
import '../../data/sample_exam_data.dart';
import '../providers/user_profile_provider.dart';

/// State for mock exam system
class MockExamState {
  final List<MockExam> exams;
  final Map<String, Map<String, int>>
  examAnswers; // examId -> questionId -> answer
  final Map<String, int> examDurations; // examId -> totalSeconds
  final Map<String, Map<String, int>>
  questionDurations; // examId -> questionId -> seconds

  const MockExamState({
    this.exams = const [],
    this.examAnswers = const {},
    this.examDurations = const {},
    this.questionDurations = const {},
  });

  MockExamState copyWith({
    List<MockExam>? exams,
    Map<String, Map<String, int>>? examAnswers,
    Map<String, int>? examDurations,
    Map<String, Map<String, int>>? questionDurations,
  }) {
    return MockExamState(
      exams: exams ?? this.exams,
      examAnswers: examAnswers ?? this.examAnswers,
      examDurations: examDurations ?? this.examDurations,
      questionDurations: questionDurations ?? this.questionDurations,
    );
  }

  /// Get answers for a specific exam
  Map<String, int> getExamAnswers(String examId) {
    return examAnswers[examId] ?? {};
  }

  /// Get progress for an exam
  double getExamProgress(String examId) {
    // Basic progress calculation (answered / total)
    // Could update this to use duration later if needed
    final exam = exams.firstWhere(
      (e) => e.id == examId,
      orElse: () =>
          MockExam(id: '', name: '', date: DateTime.now(), questions: []),
    );
    if (exam.questions.isEmpty) return 0;

    final answers = getExamAnswers(examId);
    return answers.length / exam.questions.length;
  }
}

/// Notifier for mock exam state
class MockExamNotifier extends StateNotifier<MockExamState> {
  static const _keyExamAnswers = 'exam_answers';
  static const _keyExamDurations = 'exam_durations';
  static const _keyQuestionDurations = 'question_durations';

  MockExamNotifier() : super(const MockExamState()) {
    _loadExams();
    _loadData(); // Combined load
  }

  void _loadExams() {
    state = state.copyWith(exams: SampleExamData.getAllExams());
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Answers
    final ansJson = prefs.getString(_keyExamAnswers);
    Map<String, Map<String, int>> answers = {};
    if (ansJson != null) {
      try {
        final decoded = json.decode(ansJson) as Map<String, dynamic>;
        answers = decoded.map(
          (k, v) =>
              MapEntry(k, (v as Map<String, dynamic>).cast<String, int>()),
        );
      } catch (_) {}
    }

    // Load Exam Durations
    final durJson = prefs.getString(_keyExamDurations);
    Map<String, int> durations = {};
    if (durJson != null) {
      try {
        final decoded = json.decode(durJson) as Map<String, dynamic>;
        durations = decoded.cast<String, int>();
      } catch (_) {}
    }

    // Load Question Durations
    final qDurJson = prefs.getString(_keyQuestionDurations);
    Map<String, Map<String, int>> qDurations = {};
    if (qDurJson != null) {
      try {
        final decoded = json.decode(qDurJson) as Map<String, dynamic>;
        qDurations = decoded.map(
          (k, v) =>
              MapEntry(k, (v as Map<String, dynamic>).cast<String, int>()),
        );
      } catch (_) {}
    }

    state = state.copyWith(
      examAnswers: answers,
      examDurations: durations,
      questionDurations: qDurations,
    );
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExamAnswers, json.encode(state.examAnswers));
    await prefs.setString(_keyExamDurations, json.encode(state.examDurations));
    await prefs.setString(
      _keyQuestionDurations,
      json.encode(state.questionDurations),
    );
  }

  /// Save answer for a question
  void saveAnswer(String examId, String questionId, int answer) {
    final currentAnswers = Map<String, Map<String, int>>.from(
      state.examAnswers,
    );
    final examAnswers = Map<String, int>.from(currentAnswers[examId] ?? {});
    examAnswers[questionId] = answer;
    currentAnswers[examId] = examAnswers;

    state = state.copyWith(examAnswers: currentAnswers);
    _saveAll();
  }

  /// Save total duration for an exam
  void saveExamDuration(String examId, int seconds) {
    final currentDurations = Map<String, int>.from(state.examDurations);
    currentDurations[examId] = seconds;

    state = state.copyWith(examDurations: currentDurations);
    _saveAll();
  }

  /// Save duration for a specific question
  void saveQuestionDuration(String examId, String questionId, int seconds) {
    final currentQDurations = Map<String, Map<String, int>>.from(
      state.questionDurations,
    );
    final examQDurations = Map<String, int>.from(
      currentQDurations[examId] ?? {},
    );

    examQDurations[questionId] = seconds;
    currentQDurations[examId] = examQDurations;

    state = state.copyWith(questionDurations: currentQDurations);
    _saveAll();
  }

  /// Get answer for a question
  int? getAnswer(String examId, String questionId) {
    return state.examAnswers[examId]?[questionId];
  }

  /// Clear all answers and data for an exam
  void clearExamData(String examId) {
    final currentAnswers = Map<String, Map<String, int>>.from(
      state.examAnswers,
    );
    currentAnswers.remove(examId);

    final currentDurations = Map<String, int>.from(state.examDurations);
    currentDurations.remove(examId);

    final currentQDurations = Map<String, Map<String, int>>.from(
      state.questionDurations,
    );
    currentQDurations.remove(examId);

    state = state.copyWith(
      examAnswers: currentAnswers,
      examDurations: currentDurations,
      questionDurations: currentQDurations,
    );
    _saveAll();
  }

  /// Get statistics for an exam (Total, Correct, Wrong, Net per subject)
  Map<String, SubjectStats> getExamStatistics(String examId) {
    final exam = state.exams.firstWhere(
      (e) => e.id == examId,
      orElse: () =>
          MockExam(id: '', name: '', date: DateTime.now(), questions: []),
    );

    if (exam.questions.isEmpty) return {};

    final examAnswers = state.getExamAnswers(examId);
    final stats = <String, SubjectStats>{};

    for (final question in exam.questions) {
      // Use prefixed key for consistency (e.g., "TYT - Türkçe")
      final statsKey = '${question.examType.displayName} - ${question.subject}';
      final userAnswer = examAnswers[question.id];

      if (!stats.containsKey(statsKey)) {
        stats[statsKey] = SubjectStats(subjectName: statsKey);
      }

      final current = stats[statsKey]!;

      if (userAnswer != null) {
        final isCorrect = userAnswer == question.correctAnswer;
        stats[statsKey] = current.copyWith(
          totalQuestions: current.totalQuestions + 1,
          correctAnswers: current.correctAnswers + (isCorrect ? 1 : 0),
          wrongAnswers: current.wrongAnswers + (isCorrect ? 0 : 1),
        );
      } else {
        // Increment TOTAL even if not answered
        stats[statsKey] = current.copyWith(
          totalQuestions: current.totalQuestions + 1,
        );
      }
    }

    return stats;
  }
}

/// Provider for mock exam state
final mockExamProvider = StateNotifierProvider<MockExamNotifier, MockExamState>(
  (ref) {
    return MockExamNotifier();
  },
);

/// Provider that aggregates statistics from both Practice (TestPage) and Mock Exams (DenemePage)
final aggregatedSubjectStatsProvider = Provider<Map<String, SubjectStats>>((
  ref,
) {
  final profile = ref.watch(userProfileProvider);
  final mockState = ref.watch(mockExamProvider);
  final mockNotifier = ref.read(mockExamProvider.notifier);

  // Start with practice stats from UserProfile
  final Map<String, SubjectStats> aggregated = Map.from(profile.subjectStats);

  // Add stats from all mock exams
  for (final exam in mockState.exams) {
    // Only aggregate if user has actually answered something in this exam
    if (mockState.getExamProgress(exam.id) > 0) {
      final examStats = mockNotifier.getExamStatistics(exam.id);

      examStats.forEach((key, stats) {
        if (aggregated.containsKey(key)) {
          final existing = aggregated[key]!;
          aggregated[key] = existing.copyWith(
            totalQuestions: existing.totalQuestions + stats.totalQuestions,
            correctAnswers: existing.correctAnswers + stats.correctAnswers,
            wrongAnswers: existing.wrongAnswers + stats.wrongAnswers,
          );
        } else {
          aggregated[key] = stats;
        }
      });
    }
  }

  return aggregated;
});
