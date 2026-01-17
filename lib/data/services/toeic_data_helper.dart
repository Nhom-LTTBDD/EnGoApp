// lib/data/services/toeic_data_helper.dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'toeic_upload_service.dart';
import '../datasources/remote/toeic_remote_datasource.dart';

class ToeicDataHelper {
  late final ToeicUploadService _uploadService;

  ToeicDataHelper() {
    final datasource = ToeicRemoteDatasourceImpl();
    _uploadService = ToeicUploadService(remoteDatasource: datasource);
  }

  // Upload TOEIC Test 1 with audio files from a directory
  ///
  /// Expected directory structure:
  /// toeic_test_1_audio/
  ///   ├── q001.mp3  (Question 1 - Part 1)
  ///   ├── q002.mp3  (Question 2 - Part 1)
  ///   ├── ...
  ///   ├── q006.mp3  (Question 6 - Part 1)
  ///   ├── q007.mp3  (Question 7 - Part 2)
  ///   ├── ...
  ///   └── q031.mp3  (Question 31 - Part 2)
  Future<void> uploadToeicTest1FromDirectory(String audioDirectoryPath) async {
    try {
      final audioDir = Directory(audioDirectoryPath);
      if (!audioDir.existsSync()) {
        throw Exception('Audio directory not found: $audioDirectoryPath');
      }

      print('Scanning audio directory: $audioDirectoryPath');

      // Get all audio files (mp3, wav, m4a)
      final audioFiles = <File>[];
      final supportedExtensions = ['.mp3', '.wav', '.m4a'];

      final files = audioDir
          .listSync()
          .whereType<File>()
          .where(
            (file) => supportedExtensions.contains(
              path.extension(file.path).toLowerCase(),
            ),
          )
          .toList();

      // Sort files by question number (assuming format: q001.mp3, q002.mp3, etc.)
      files.sort((a, b) {
        final aName = path.basenameWithoutExtension(a.path);
        final bName = path.basenameWithoutExtension(b.path);
        return aName.compareTo(bName);
      });

      if (files.isEmpty) {
        throw Exception('No audio files found in directory');
      }

      if (files.length != 31) {
        print('Warning: Expected 31 audio files, found ${files.length}');
      }

      // Take only the first 31 files
      final first31Files = files.take(31).toList();
      audioFiles.addAll(first31Files);

      print('Found ${audioFiles.length} audio files:');
      for (int i = 0; i < audioFiles.length; i++) {
        final fileName = path.basename(audioFiles[i].path);
        final partNumber = i < 6
            ? 1
            : 2; // Questions 1-6: Part 1, Questions 7-31: Part 2
        print('  ${i + 1}. $fileName (Part $partNumber)');
      }

      print('\n🚀 Starting upload to Firebase...');

      await _uploadService.uploadToeicTest1With31ListeningQuestions(
        audioFiles: audioFiles,
        testName: '2024 Practice Set TOEIC Test 1',
        description:
            'TOEIC listening practice test with 31 questions (Part 1: 6 questions, Part 2: 25 questions)',
      );

      print('\nUpload completed successfully!');
      print('Test Data:');
      print('   - Test ID: toeic_test_001');
      print('   - Questions: 31 (Listening only)');
      print('   - Part 1: Questions 1-6 (Photos)');
      print('   - Part 2: Questions 7-31 (Question-Response)');
      print('   - Audio files: Uploaded to Firebase Storage');
      print('   - Question data: Saved to Firestore');
    } catch (e) {
      print('Upload failed: $e');
      rethrow;
    }
  }

  /// Upload specific audio files by providing a map
  Future<void> uploadToeicTest1FromFileMap(
    Map<int, String> questionAudioMap,
  ) async {
    try {
      final audioFiles = <File>[];

      // Sort by question number and convert to File objects
      final sortedEntries = questionAudioMap.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final entry in sortedEntries) {
        final file = File(entry.value);
        if (!file.existsSync()) {
          throw Exception('Audio file not found: ${entry.value}');
        }
        audioFiles.add(file);
      }

      await _uploadService.uploadToeicTest1With31ListeningQuestions(
        audioFiles: audioFiles,
        testName: '2024 Practice Set TOEIC Test 1',
      );

      print('✅ Upload from file map completed!');
    } catch (e) {
      print('❌ Upload failed: $e');
      rethrow;
    }
  }

  /// Print Firebase Storage structure for reference
  void printStorageStructure() {
    print('''
📁 Firebase Storage Structure:
toeic_audio/
├── toeic_test_001/
│   ├── q001.mp3  (Part 1, Question 1)
│   ├── q002.mp3  (Part 1, Question 2)
│   ├── q003.mp3  (Part 1, Question 3)
│   ├── q004.mp3  (Part 1, Question 4)
│   ├── q005.mp3  (Part 1, Question 5)
│   ├── q006.mp3  (Part 1, Question 6)
│   ├── q007.mp3  (Part 2, Question 7)
│   ├── q008.mp3  (Part 2, Question 8)
│   ├── ...
│   └── q031.mp3  (Part 2, Question 31)

🔥 Firestore Collections:
📄 toeic_tests/toeic_test_001
📄 toeic_questions/toeic_test_001_q001
📄 toeic_questions/toeic_test_001_q002
📄 ...
📄 toeic_questions/toeic_test_001_q031
''');
  }
}

// Usage example:
/*
void main() async {
  final helper = ToeicDataHelper();
  
  // Method 1: Upload from directory
  await helper.uploadToeicTest1FromDirectory('/path/to/toeic_audio_files');
  
  // Method 2: Upload specific files
  await helper.uploadToeicTest1FromFileMap({
    1: '/path/to/q001.mp3',
    2: '/path/to/q002.mp3',
    // ... up to 31
    31: '/path/to/q031.mp3',
  });
  
  // Print structure
  helper.printStorageStructure();
}
*/
