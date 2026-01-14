// lib/data/services/toeic_upload_service.dart

import 'dart:io';
import '../datasources/remote/toeic_remote_datasource.dart';
import '../models/toeic_test_model.dart';
import '../models/toeic_question_model.dart';
import '../../domain/entities/toeic_test.dart';
import '../../domain/entities/toeic_question.dart';

class ToeicUploadService {
  final ToeicRemoteDatasource _remoteDatasource;

  ToeicUploadService({required ToeicRemoteDatasource remoteDatasource})
    : _remoteDatasource = remoteDatasource;

  /// Upload complete TOEIC test with 31 listening questions and audio files
  Future<void> uploadToeicTest1With31ListeningQuestions({
    required List<File> audioFiles, // 31 audio files
    required String testName,
    String? description,
  }) async {
    const testId = 'toeic_test_001';

    try {
      print('Starting upload for TOEIC Test 1...');

      // 1. Create test metadata
      final test = ToeicTest(
        id: testId,
        name: testName,
        description:
            description ?? 'TOEIC Practice Test 1 with 31 listening questions',
        totalQuestions: 31,
        listeningQuestions: 31,
        readingQuestions: 0, // Only listening for now
        duration: 45, // 45 minutes for listening
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        year: DateTime.now().year,
      );

      final testModel = ToeicTestModel.fromEntity(test);
      await _remoteDatasource.uploadToeicTest(testModel);
      print('✅ Test metadata uploaded');

      // 2. Upload audio files and create questions
      final questions = <ToeicQuestionModel>[];

      for (int i = 0; i < audioFiles.length; i++) {
        final questionNumber = i + 1;
        final partNumber = _getPartNumber(questionNumber);

        print('Uploading audio for question $questionNumber...');

        // Upload audio file
        final audioUrl = await _remoteDatasource.uploadAudioFile(
          audioFiles[i],
          testId,
          questionNumber,
        );

        // Create question
        final question = _createListeningQuestion(
          testId: testId,
          questionNumber: questionNumber,
          partNumber: partNumber,
          audioUrl: audioUrl,
        );

        questions.add(ToeicQuestionModel.fromEntity(question));
        print('✅ Question $questionNumber uploaded');
      }

      // 3. Upload all questions
      await _remoteDatasource.uploadToeicQuestions(questions);
      print('All questions uploaded to Firestore');
      print('TOEIC Test 1 upload completed successfully!');
    } catch (e) {
      print('Error uploading TOEIC test: $e');
      rethrow;
    }
  }

  /// Determine part number based on question number
  int _getPartNumber(int questionNumber) {
    if (questionNumber >= 1 && questionNumber <= 6) {
      return 1; // Part 1: Photos (6 questions)
    } else if (questionNumber >= 7 && questionNumber <= 31) {
      return 2; // Part 2: Question-Response (25 questions)
    } else if (questionNumber >= 32 && questionNumber <= 70) {
      return 3; // Part 3: Conversations (39 questions)
    } else if (questionNumber >= 71 && questionNumber <= 100) {
      return 4; // Part 4: Talks (30 questions)
    }
    return 1; // Default to Part 1
  }

  /// Create listening question entity
  ToeicQuestion _createListeningQuestion({
    required String testId,
    required int questionNumber,
    required int partNumber,
    required String audioUrl,
  }) {
    String questionType;
    String? questionText;
    String? imageUrl;
    List<String> options;

    if (partNumber == 1) {
      // Part 1: Photo description
      questionType = 'image-audio';
      questionText = null; // No text for Part 1
      imageUrl =
          'https://picsum.photos/400/300?random=$questionNumber'; // Placeholder image
      options = ['A', 'B', 'C', 'D'];
    } else {
      // Part 2: Question-Response
      questionType = 'audio-only';
      questionText = null; // Audio only
      imageUrl = null;
      options = ['A', 'B', 'C'];
    }

    return ToeicQuestion(
      id: '${testId}_q${questionNumber.toString().padLeft(3, '0')}',
      testId: testId,
      partNumber: partNumber,
      questionNumber: questionNumber,
      questionType: questionType,
      questionText: questionText,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      options: options,
      correctAnswer: 'A', // Default - should be updated with real answers
      explanation: 'Explanation for question $questionNumber',
      order: questionNumber,
      groupId: null,
      passageText: null,
    );
  }

  /// Upload individual audio files for existing questions
  Future<void> updateQuestionsWithAudio(
    String testId,
    Map<int, File> questionAudioMap, // questionNumber -> audioFile
  ) async {
    try {
      for (final entry in questionAudioMap.entries) {
        final questionNumber = entry.key;
        final audioFile = entry.value;

        print('Uploading audio for question $questionNumber...');

        final audioUrl = await _remoteDatasource.uploadAudioFile(
          audioFile,
          testId,
          questionNumber,
        );

        // Update question in Firestore with audio URL
        // This would require an update method in the datasource
        print('✅ Audio uploaded for question $questionNumber: $audioUrl');
      }
    } catch (e) {
      print('❌ Error updating questions with audio: $e');
      rethrow;
    }
  }
}
