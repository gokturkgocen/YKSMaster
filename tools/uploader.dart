import 'dart:convert';
import 'dart:io';
import 'package:firedart/firedart.dart';
import 'package:path/path.dart' as p;

/// Standalone CLI tool to upload questions from questions.json to Firestore.
///
/// TO RUN:
/// 1. cd tools
/// 2. dart pub get
/// 3. Get your Firebase Project ID and an API Key (from Firebase Console Settings)
/// 4. dart run uploader.dart <PROJECT_ID> <API_KEY>
void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run uploader.dart <PROJECT_ID> <API_KEY>');
    print('Example: dart run uploader.dart yks-master-123 AIzaSyB...');
    exit(1);
  }

  final projectId = args[0];
  final apiKey = args[1];

  print('🚀 Initializing YKS Master Uploader...');

  // Initialize Firestore
  Firestore.initialize(projectId);

  // Load JSON file
  final jsonPath = p.join(Directory.current.path, 'questions.json');
  final file = File(jsonPath);

  if (!await file.exists()) {
    print('❌ Error: questions.json not found at $jsonPath');
    exit(1);
  }

  final content = await file.readAsString();
  final List<dynamic> questionsJson = jsonDecode(content);

  print('📝 Found ${questionsJson.length} questions. Starting upload...');

  final collection = Firestore.instance.collection('questions');

  for (var i = 0; i < questionsJson.length; i++) {
    final q = questionsJson[i];
    final id =
        q['id']?.toString() ?? 'q_${DateTime.now().millisecondsSinceEpoch}_$i';

    try {
      await collection.document(id).set(q);
      print('✅ [$i/${questionsJson.length}] Uploaded: $id');
    } catch (e) {
      print('❌ Error uploading $id: $e');
    }
  }

  print('\n🎉 All done! Your questions are now live in YKS Master.');
}
