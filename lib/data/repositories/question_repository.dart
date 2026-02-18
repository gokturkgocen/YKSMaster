import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/mock_exam.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore;

  QuestionRepository(this._firestore);

  /// Fetch questions from Firestore "questions" collection
  /// Filter by exam type and subject if provided
  Future<List<ExamQuestion>> getQuestions(ExamType type, String subject) async {
    try {
      final querySnapshot = await _firestore
          .collection('questions')
          .where('examType', isEqualTo: type.name)
          .where('subject', isEqualTo: subject)
          .get();

      return querySnapshot.docs
          .map((doc) => ExamQuestion.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  /// Add a question to Firestore (Admin/Seeding use)
  Future<void> addQuestion(ExamQuestion question) async {
    await _firestore
        .collection('questions')
        .doc(question.id)
        .set(question.toMap());
  }

  /// Bulk add questions (Seeding)
  Future<void> addQuestions(List<ExamQuestion> questions) async {
    final batch = _firestore.batch();
    for (final q in questions) {
      final docRef = _firestore.collection('questions').doc(q.id);
      batch.set(docRef, q.toMap());
    }
    await batch.commit();
  }
}
