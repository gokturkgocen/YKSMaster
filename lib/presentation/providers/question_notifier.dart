import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mock_exam.dart';

/// State for question navigation
class QuestionState {
  final List<ExamQuestion> questions;
  final int currentIndex;
  final int? selectedAnswer; // null if not answered
  final Map<String, int> answers; // questionId (String) -> selectedOption

  const QuestionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.answers = const {},
  });

  ExamQuestion get currentQuestion => questions.isNotEmpty
      ? questions[currentIndex]
      : const ExamQuestion(
          id: 'loading',
          subject: '',
          questionText: 'Sorular yükleniyor...',
          options: [],
          correctAnswer: 0,
          examType: ExamType.tyt,
        );

  int get totalQuestions => questions.length;
  bool get canGoNext => currentIndex < questions.length - 1;
  bool get canGoPrevious => currentIndex > 0;
  bool get isLoading => questions.isEmpty;

  QuestionState copyWith({
    List<ExamQuestion>? questions,
    int? currentIndex,
    int? selectedAnswer,
    Map<String, int>? answers,
    bool clearSelectedAnswer = false,
  }) {
    return QuestionState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: clearSelectedAnswer
          ? null
          : (selectedAnswer ?? this.selectedAnswer),
      answers: answers ?? this.answers,
    );
  }
}

/// Notifier for question state
class QuestionNotifier extends StateNotifier<QuestionState> {
  QuestionNotifier() : super(const QuestionState());

  void setQuestions(List<ExamQuestion> questions) {
    state = QuestionState(questions: questions);
  }

  void selectAnswer(int optionIndex) {
    if (state.questions.isEmpty) return;

    final newAnswers = Map<String, int>.from(state.answers);
    newAnswers[state.currentQuestion.id] = optionIndex;

    state = state.copyWith(selectedAnswer: optionIndex, answers: newAnswers);
  }

  void nextQuestion() {
    if (state.canGoNext) {
      final nextIndex = state.currentIndex + 1;
      final nextQuestion = state.questions[nextIndex];
      final existingAnswer = state.answers[nextQuestion.id];

      state = state.copyWith(
        currentIndex: nextIndex,
        selectedAnswer: existingAnswer,
        clearSelectedAnswer: existingAnswer == null,
      );
    }
  }

  void previousQuestion() {
    if (state.canGoPrevious) {
      final prevIndex = state.currentIndex - 1;
      final prevQuestion = state.questions[prevIndex];
      final existingAnswer = state.answers[prevQuestion.id];

      state = state.copyWith(
        currentIndex: prevIndex,
        selectedAnswer: existingAnswer,
        clearSelectedAnswer: existingAnswer == null,
      );
    }
  }
}

/// Provider for question state
final questionProvider = StateNotifierProvider<QuestionNotifier, QuestionState>(
  (ref) => QuestionNotifier(),
);
