import '../domain/models/mock_exam.dart';

/// Generate sample exam data for testing
class SampleExamData {
  static MockExam getSampleExam() {
    return MockExam(
      id: 'exam_001',
      name: 'Deneme Sınavı 1',
      date: DateTime.now(),
      questions: const [],
    );
  }

  /// Get a practice exam for a specific subject
  static MockExam getPracticeExam(String subject, {ExamType? type}) {
    return MockExam(
      id: 'practice_${DateTime.now().millisecondsSinceEpoch}',
      name: '$subject Testi',
      date: DateTime.now(),
      questions: const [],
    );
  }

  /// Get all sample exams (for list view)
  static List<MockExam> getAllExams() {
    return [
      MockExam(
        id: 'exam_003',
        name: 'Deneme Sınavı 3',
        date: DateTime.now(),
        questions: const [],
      ),
      MockExam(
        id: 'exam_002',
        name: 'Deneme Sınavı 2',
        date: DateTime.now().subtract(const Duration(days: 7)),
        questions: const [],
      ),
      getSampleExam(), // Exam 1 with empty questions
    ];
  }
}
