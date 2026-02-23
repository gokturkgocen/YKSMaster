import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('questions.json');
  final content = file.readAsStringSync();
  final List<dynamic> questions = jsonDecode(content);

  final ids = <String>{};
  final duplicates = <String>[];
  final missingIds = <int>[];
  final subjects = <String, int>{};

  for (var i = 0; i < questions.length; i++) {
    final q = questions[i];
    final idStr = q['id']?.toString();

    if (idStr == null) {
      missingIds.add(i);
    } else {
      if (ids.contains(idStr)) {
        duplicates.add(idStr);
      }
      ids.add(idStr);
    }

    final sub = q['subject']?.toString() ?? 'MISSING';
    subjects[sub] = (subjects[sub] ?? 0) + 1;
  }

  print('Total Questions: ${questions.length}');
  print('Unique IDs: ${ids.length}');
  if (duplicates.isNotEmpty) {
    print('Duplicate IDs: ${duplicates.toSet().toList()}');
  }
  if (missingIds.isNotEmpty) {
    print('Indices with missing IDs: $missingIds');
  }
  print('Subjects distribution: $subjects');
}
