// lib/data/services/toeic_json_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';
import 'firebase_storage_service.dart';

class ToeicJsonService {
  // Use Firebase Storage service for data loading
  static Future<Map<String, dynamic>> loadJsonData() async {
    return await FirebaseStorageService.loadJsonData();
  }

  static Future<ToeicTest> loadTest(String testId) async {
    return await FirebaseStorageService.loadTest(testId);
  }

  static Future<List<ToeicQuestion>> loadQuestionsByPart(
    String testId,
    int partNumber,
  ) async {
    try {
      print('🔥 Loading questions for test: $testId, part: $partNumber from Firebase');
      
      // Use Firebase Storage service
      return await FirebaseStorageService.loadQuestionsByPart(partNumber);
    } catch (e) {
      print('❌ Error loading questions for part $partNumber from Firebase: $e');
      
      // Fallback to local loading
      print('🔄 Falling back to local assets...');
      return await _loadQuestionsFromLocalAssets(testId, partNumber);
    }
  }

  /// Fallback method to load from local assets
  static Future<List<ToeicQuestion>> _loadQuestionsFromLocalAssets(
    String testId,
    int partNumber,
  ) async {
    try {
      print('Loading questions from local assets for test: $testId, part: $partNumber');
      final String jsonString = await rootBundle.loadString('assets/toeic_questions.json');
      final data = json.decode(jsonString);

      if (data.isEmpty) {
        print('No JSON data loaded');
        return [];
      }

      final testData = data[testId];
      if (testData == null) {
        print('Test $testId not found in JSON data');
        return [];
      }

      final partsData = testData['parts'];
      if (partsData == null) {
        print('No parts data found for test $testId');
        return [];
      }

      final partData = partsData[partNumber.toString()];
      if (partData == null) {
        print('Part $partNumber not found in test $testId');
        return [];
      }

      final questionsData = partData['questions'];
      if (questionsData == null || questionsData is! List) {
        print('No questions data found for part $partNumber');
        return [];
      }

      print('Found ${questionsData.length} questions for part $partNumber');

      final questions = <ToeicQuestion>[];

      for (var questionData in questionsData) {
        try {
          // Handle both imageFile (single) and imageFiles (array)
          String? imageUrl;
          List<String>? imageUrls;

          if (questionData['imageFile'] != null) {
            imageUrl = _getImagePath(questionData['imageFile']);
          } else if (questionData['imageFiles'] != null &&
              questionData['imageFiles'] is List) {
            imageUrls = (questionData['imageFiles'] as List<dynamic>)
                .map((file) => _getImagePath(file))
                .where((url) => url != null)
                .cast<String>()
                .toList();
            if (imageUrls.isNotEmpty) {
              imageUrl = imageUrls.first; // Use first image as primary
            }
          }

          final audioUrl = _getAudioPath(questionData['audioFile']);

          print(
            'Question ${questionData['questionNumber']}: imageFile=${questionData['imageFile']}, imageFiles=${questionData['imageFiles']}, imageUrl=$imageUrl',
          );

          final question = ToeicQuestion(
            id: 'q${questionData['questionNumber']}',
            testId: testId,
            partNumber: partNumber,
            questionNumber: questionData['questionNumber'],
            questionType: questionData['questionType'] ?? 'multiple-choice',
            questionText: questionData['questionText'],
            imageUrl: imageUrl,
            imageUrls: imageUrls,
            audioUrl: audioUrl,
            options: List<String>.from(questionData['options'] ?? []),
            correctAnswer: questionData['correctAnswer'] ?? 'A',
            explanation: questionData['explanation'] ?? '',
            transcript:
                questionData['transcript'] ?? questionData['audioTranscript'],
            order: questionData['questionNumber'],
            groupId: questionData['groupId'],
            passageText: questionData['passageText'],
          );
          questions.add(question);
        } catch (e) {
          print('Error creating question: $e');
        }
      }

      print('Successfully created ${questions.length} ToeicQuestion objects');
      return questions;
    } catch (e) {
      print('Error loading questions for part $partNumber from local assets: $e');
      return [];
    }
  }

  static Future<List<ToeicQuestion>> loadAllQuestions(String testId) async {
    final allQuestions = <ToeicQuestion>[];

    // Load questions from all parts
    for (int part = 1; part <= 7; part++) {
      final partQuestions = await loadQuestionsByPart(testId, part);
      allQuestions.addAll(partQuestions);
    }

    // Sort by question number
    allQuestions.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    return allQuestions;
  }

  static String? _getImagePath(String? imageFile) {
    if (imageFile == null) return null;
    // Convert .jpg to .png as all images are in PNG format
    String correctedImageFile = imageFile;
    if (imageFile.endsWith('.jpg')) {
      correctedImageFile = imageFile.replaceAll('.jpg', '.png');
    }
    String finalPath = 'assets/test_toeic/test_1/$correctedImageFile';
    return finalPath;
  }

  static String? _getAudioPath(String? audioFile) {
    if (audioFile == null) return null;
    return 'assets/audio/toeic_test1/$audioFile';
  }

  static Map<String, List<ToeicQuestion>> groupQuestionsByPart(
    List<ToeicQuestion> questions,
  ) {
    final Map<String, List<ToeicQuestion>> grouped = {};

    for (var question in questions) {
      final partKey = 'part${question.partNumber}';
      if (!grouped.containsKey(partKey)) {
        grouped[partKey] = [];
      }
      grouped[partKey]!.add(question);
    }

    return grouped;
  }
}