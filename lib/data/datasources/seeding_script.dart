import 'package:flutter/widgets.dart';
import '../../domain/models/mock_exam.dart';
import '../sample_exam_data.dart';
import '../repositories/question_repository.dart';

/// Helper to seed database with sample questions
Future<void> seedDatabase(QuestionRepository repo) async {
  debugPrint('Starting database seeding...');

  try {
    // 1. Seed Questions
    // sampleQuestions is expected to be a List<ExamQuestion> or similar,
    // depending on what sample_exam_data.dart exports.
    // Let's assume it exports `mockExamData` which is a MockExam.

    // We need to verify what sample_exam_data.dart exports.
    // Based on previous context, it likely contains Turkish questions.

    // For now, let's assume we can access a list of questions.
    // If sample_exam_data.dart exports a variable, we use it.
    // If not, we might need to modify it or copy data.

    // Placeholder implementation relying on mockExamData if available,
    // or manual list if not.

    // Use the sample exam data which contains all types of questions
    final sampleExam = SampleExamData.getSampleExam();
    final List<ExamQuestion> allQuestions = sampleExam.questions;

    if (allQuestions.isNotEmpty) {
      // Use batching for large lists effectively
      // Firestore batch limit is 500 operations
      int batchSize = 400;
      for (var i = 0; i < allQuestions.length; i += batchSize) {
        var end = (i + batchSize < allQuestions.length)
            ? i + batchSize
            : allQuestions.length;
        var batchList = allQuestions.sublist(i, end);
        await repo.addQuestions(batchList);
        debugPrint(' seeded batch ${i ~/ batchSize + 1}');
      }
      debugPrint('Seeded total ${allQuestions.length} questions.');
    } else {
      debugPrint('No questions to seed.');
    }
  } catch (e) {
    debugPrint('Error seeding database: $e');
  }
}
