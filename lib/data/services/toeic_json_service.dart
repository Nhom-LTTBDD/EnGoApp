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
  /// Load questions theo thứ tự ưu tiên:
  /// Firebase Storage -> Local Assets -> Demo
  /// ==============================
  static Future<List<ToeicQuestion>> loadQuestionsByPart(
    String testId,
    int partNumber,
  ) async {
    try {
      // Thử load từ Firebase Storage trước
      print(
        '🔥 Trying to load questions from Firebase Storage | test=$testId | part=$partNumber',
      );
      return await _loadQuestionsFromFirebaseStorage(testId, partNumber);
    } catch (firebaseError) {
      print('❌ Firebase Storage failed: $firebaseError');

      try {
        print(
          '📁 Fallback to loading questions from local assets | test=$testId | part=$partNumber',
        );
        return await _loadQuestionsFromLocalAssets(testId, partNumber);
      } catch (localError) {
        print('❌ Local assets failed: $localError');
        print('🚑 Final fallback to demo questions');

        return _createDemoQuestions(testId, partNumber);
      }
    }
  }

  /// Load questions từ Firebase Storage
  static Future<List<ToeicQuestion>> _loadQuestionsFromFirebaseStorage(
    String testId,
    int partNumber,
  ) async {
    print('🔥 Firebase Storage: load | test=$testId | part=$partNumber');

    // Sử dụng FirebaseStorageService để load JSON data trực tiếp
    final jsonData = await FirebaseStorageService.loadJsonData();

    // Parse JSON để lấy questions cho test và part cụ thể
    final testData = jsonData[testId];
    if (testData == null) {
      throw Exception('Test $testId not found in Firebase Storage');
    }

    final parts = testData['parts'] as Map<String, dynamic>?;
    if (parts == null) {
      throw Exception('Parts data not found for test $testId');
    }

    final partData = parts[partNumber.toString()];
    if (partData == null) {
      throw Exception('Part $partNumber not found for test $testId');
    }

    final questionsData = partData['questions'] as List<dynamic>?;
    if (questionsData == null) {
      throw Exception('Questions data not found for part $partNumber');
    }

    final questions = <ToeicQuestion>[];
    for (final q in questionsData) {
      questions.add(
        _mapJsonToQuestion(testId, partNumber, q as Map<String, dynamic>),
      );
    }

    print('✅ Loaded ${questions.length} questions from Firebase Storage');
    return questions;
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
    // image - sử dụng Firebase Storage reference
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

    // audio - sử dụng Firebase Storage reference
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

    // Log để debug tên file
    print('🖼️ Creating image reference for: $imageFile');
    
    // Return Firebase Storage path - sẽ được convert thành download URL khi cần
    return 'firebase_image:$imageFile';
  }

  static String? _getAudioPath(String testId, String? audioFile) {
    if (audioFile == null) return null;

    // Log để debug tên file
    print('🎵 Creating audio reference for: $audioFile');
    
    // Return Firebase Storage path - sẽ được convert thành download URL khi cần
    return 'firebase_audio:$audioFile';
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
