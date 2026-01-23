// lib/data/services/toeic_json_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';

import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';
import 'firebase_storage_service.dart';

class ToeicJsonService {
  /// ==============================
  /// LOAD TEST
  /// ==============================
  static Future<ToeicTest> loadTest(String testId) async {
    return FirebaseStorageService.loadTest(testId);
  }

  /// ==============================
  /// LOAD QUESTIONS BY PART
  /// Firebase -> Local -> Demo
  /// ==============================
  static Future<List<ToeicQuestion>> loadQuestionsByPart(
    String testId,
    int partNumber,
  ) async {
    // Skip Firebase completely and disable it to prevent 404 errors
    print('🚫 Disabling Firebase Storage to use local assets only');
    FirebaseStorageService.disableFirebaseStorage();
    
    try {
      print('📁 Loading questions from local assets | test=$testId | part=$partNumber');
      return await _loadQuestionsFromLocalAssets(testId, partNumber);
    } catch (localError) {
      print('❌ Local assets failed: $localError');
      print('🚑 Fallback to demo questions');

      return _createDemoQuestions(testId, partNumber);
    }
  }

  /// ==============================
  /// LOAD ALL QUESTIONS (PART 1 → 7)
  /// ==============================
  static Future<List<ToeicQuestion>> loadAllQuestions(String testId) async {
    final allQuestions = <ToeicQuestion>[];

    for (int part = 1; part <= 7; part++) {
      final partQuestions = await loadQuestionsByPart(testId, part);
      allQuestions.addAll(partQuestions);
    }

    allQuestions.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    return allQuestions;
  }

  /// ==============================
  /// LOCAL ASSETS LOADER
  /// ==============================
  static Future<List<ToeicQuestion>> _loadQuestionsFromLocalAssets(
    String testId,
    int partNumber,
  ) async {
    print('📁 Local assets: load | test=$testId | part=$partNumber');

    final jsonString = await rootBundle.loadString(
      'assets/toeic_questions.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

    final testData = data[testId];
    if (testData == null) {
      throw Exception('Test $testId not found');
    }

    final parts = testData['parts'] as Map<String, dynamic>;
    final partData = parts[partNumber.toString()];
    if (partData == null) {
      throw Exception('Part $partNumber not found');
    }

    final questionsData = partData['questions'] as List<dynamic>;
    final questions = <ToeicQuestion>[];

    for (final q in questionsData) {
      questions.add(_mapJsonToQuestion(testId, partNumber, q));
    }

    print('✅ Loaded ${questions.length} questions from local assets');
    return questions;
  }

  /// ==============================
  /// JSON → ENTITY
  /// ==============================
  static ToeicQuestion _mapJsonToQuestion(
    String testId,
    int partNumber,
    Map<String, dynamic> json,
  ) {
    // image
    String? imageUrl;
    List<String>? imageUrls;

    if (json['imageFile'] != null) {
      imageUrl = _getImagePath(testId, json['imageFile']);
    } else if (json['imageFiles'] is List) {
      imageUrls = (json['imageFiles'] as List)
          .map((e) => _getImagePath(testId, e))
          .whereType<String>()
          .toList();

      if (imageUrls.isNotEmpty) {
        imageUrl = imageUrls.first;
      }
    }

    // audio
    final audioUrl = _getAudioPath(testId, json['audioFile']);

    return ToeicQuestion(
      id: 'q${json['questionNumber']}',
      testId: testId,
      partNumber: partNumber,
      questionNumber: json['questionNumber'],
      questionType: json['questionType'] ?? 'multiple-choice',
      questionText: json['questionText'],
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      audioUrl: audioUrl,
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 'A',
      explanation: json['explanation'] ?? '',
      transcript: json['transcript'] ?? json['audioTranscript'],
      order: json['questionNumber'],
      groupId: json['groupId'],
      passageText: json['passageText'],
    );
  }

  /// ==============================
  /// PATH HELPERS
  /// ==============================
  static String? _getImagePath(String testId, String? imageFile) {
    if (imageFile == null) return null;

    final fixed = imageFile.endsWith('.jpg')
        ? imageFile.replaceAll('.jpg', '.png')
        : imageFile;

    return 'assets/test_toeic/test_1/$fixed';
  }

  static String? _getAudioPath(String testId, String? audioFile) {
    if (audioFile == null) return null;
    return 'assets/audio/toeic_test1/$audioFile';
  }

  /// ==============================
  /// GROUP BY PART
  /// ==============================
  static Map<String, List<ToeicQuestion>> groupQuestionsByPart(
    List<ToeicQuestion> questions,
  ) {
    final Map<String, List<ToeicQuestion>> grouped = {};

    for (final q in questions) {
      final key = 'part${q.partNumber}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(q);
    }

    return grouped;
  }

  /// ==============================
  /// DEMO QUESTIONS (LAST FALLBACK)
  /// ==============================
  static List<ToeicQuestion> _createDemoQuestions(
    String testId,
    int partNumber,
  ) {
    return [
      ToeicQuestion(
        id: 'demo_${partNumber}_1',
        testId: testId,
        partNumber: partNumber,
        questionNumber: partNumber * 10,
        questionType: 'demo',
        questionText: 'Demo question for Part $partNumber',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        explanation: 'Demo explanation',
        order: partNumber * 10,
      ),
    ];
  }
}
