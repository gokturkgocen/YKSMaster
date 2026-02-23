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

      final questions = querySnapshot.docs
          .map((doc) => ExamQuestion.fromMap(doc.data()))
          .toList();

      // Robust numeric/natural sort
      questions.sort((a, b) {
        // Try parsing IDs as integers for clean sequential sorting
        final intA = int.tryParse(a.id);
        final intB = int.tryParse(b.id);

        if (intA != null && intB != null) {
          return intA.compareTo(intB);
        }

        // Fallback to double or string comparison if not simple integers
        final doubleA = double.tryParse(a.id) ?? 0;
        final doubleB = double.tryParse(b.id) ?? 0;
        if (doubleA != 0 || doubleB != 0) {
          return doubleA.compareTo(doubleB);
        }

        return a.id.compareTo(b.id);
      });

      return questions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  /// Fetch specific questions by their IDs
  Future<List<ExamQuestion>> getQuestionsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      // Create chunks of 10 for whereIn clause (Firestore limit)
      final List<ExamQuestion> results = [];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);

        final querySnapshot = await _firestore
            .collection('questions')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        results.addAll(
          querySnapshot.docs.map((doc) => ExamQuestion.fromMap(doc.data())),
        );
      }
      return results;
    } catch (e) {
      print('Error fetching questions by IDs: $e');
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
