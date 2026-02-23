import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mock_exam.dart';
import 'question_provider.dart';
import 'user_profile_provider.dart';

/// Provider that fetches questions for the Mistake Notebook
final mistakeQuestionsProvider = FutureProvider<List<ExamQuestion>>((
  ref,
) async {
  final userProfile = ref.watch(userProfileProvider);
  final questionRepo = ref.watch(questionRepositoryProvider);

  if (userProfile.wrongQuestionIds.isEmpty) return [];

  return await questionRepo.getQuestionsByIds(userProfile.wrongQuestionIds);
});
