// Mock exam data models

enum ExamType {
  tyt('TYT'),
  ayt('AYT');

  final String displayName;
  const ExamType(this.displayName);
}

/// Single question in an exam
class ExamQuestion {
  final String id;
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctAnswer; // 0-4 for A-E (Gemini provided 5 options)
  final ExamType examType;
  final String? explanation;
  final Map<String, dynamic>? metadata;

  const ExamQuestion({
    required this.id,
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.examType,
    this.explanation,
    this.metadata,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(), // Ensure ID is string
      'subject': subject,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'examType': examType.name,
      'explanation': explanation,
      'metadata': metadata,
    };
  }

  /// Create from Firestore Map
  factory ExamQuestion.fromMap(Map<String, dynamic> map) {
    return ExamQuestion(
      id: map['id']?.toString() ?? '',
      subject: map['subject'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      // Handle both correctAnswer and correctAnswerIndex (Gemini's format)
      correctAnswer: map['correctAnswer'] ?? map['correctAnswerIndex'] ?? 0,
      examType: ExamType.values.firstWhere(
        (e) => e.name == map['examType'],
        orElse: () => ExamType.tyt,
      ),
      explanation: map['explanation'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }
}

/// Mock exam containing multiple questions
class MockExam {
  final String id;
  final String name;
  final DateTime date;
  final List<ExamQuestion> questions;

  const MockExam({
    required this.id,
    required this.name,
    required this.date,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory MockExam.fromMap(Map<String, dynamic> map) {
    return MockExam(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map((q) => ExamQuestion.fromMap(q))
              .toList() ??
          [],
    );
  }

  /// Get questions by exam type
  List<ExamQuestion> getQuestionsByType(ExamType type) {
    return questions.where((q) => q.examType == type).toList();
  }

  /// Get questions by subject, optionally filtered by type
  List<ExamQuestion> getQuestionsBySubject(String subject, {ExamType? type}) {
    return questions.where((q) {
      final subjectMatch = q.subject == subject;
      if (type != null) {
        return subjectMatch && q.examType == type;
      }
      return subjectMatch;
    }).toList();
  }

  /// Get unique subjects for an exam type
  List<String> getSubjectsForType(ExamType type) {
    final typeQuestions = getQuestionsByType(type);
    return typeQuestions.map((q) => q.subject).toSet().toList();
  }

  /// Calculate progress (answered questions / total)
  double getProgress(Map<String, int> answers) {
    if (questions.isEmpty) return 0;
    final answeredCount = questions
        .where((q) => answers.containsKey(q.id))
        .length;
    return answeredCount / questions.length;
  }
}
