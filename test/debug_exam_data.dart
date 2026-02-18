import 'package:yks_vision_tablet/data/sample_exam_data.dart';
import 'package:yks_vision_tablet/domain/models/mock_exam.dart';

void main() {
  final exam = SampleExamData.getSampleExam();
  print('Exam: ${exam.name}');

  final distribution = <String, int>{};

  for (final q in exam.questions) {
    final key = '${q.examType.displayName} - ${q.subject}';
    distribution[key] = (distribution[key] ?? 0) + 1;
  }

  print('--- Question Distribution ---');
  final sortedKeys = distribution.keys.toList()..sort();
  for (final key in sortedKeys) {
    print('$key: ${distribution[key]}');
  }

  print('--- Total Check ---');
  final tytFen = distribution['TYT - Fen Bilimleri'] ?? 0;
  final aytFen = distribution['AYT - Fen Bilimleri'] ?? 0;
  print('TYT Fen Expected: 20, Actual: $tytFen');
  print('AYT Fen Expected: 40, Actual: $aytFen');
}
