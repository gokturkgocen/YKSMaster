import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/question_repository.dart';
import '../../domain/models/mock_exam.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(FirebaseFirestore.instance);
});

final questionsProvider =
    FutureProvider.family<
      List<ExamQuestion>,
      ({ExamType type, String subject})
    >((ref, params) async {
      final repo = ref.watch(questionRepositoryProvider);
      return repo.getQuestions(params.type, params.subject);
    });
