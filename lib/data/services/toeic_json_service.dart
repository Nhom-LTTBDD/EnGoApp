/// ToeicJsonService - Parse JSON từ Firebase → Dart objects

import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';
import 'firebase_storage_service.dart';

class ToeicJsonService {
  /// Load test metadata từ Firebase
  static Future<ToeicTest> loadTest(String testId) async {
    return FirebaseStorageService.loadTest(testId);
  }

  /// Load questions cho một part (1-7)
  static Future<List<ToeicQuestion>> loadQuestionsByPart(
    String testId,
    int partNumber,
  ) async {
    return await _loadQuestionsFromFirebaseStorage(testId, partNumber);
  }

  /// Internal: Load từ Firebase và parse JSON → ToeicQuestion objects
  static Future<List<ToeicQuestion>> _loadQuestionsFromFirebaseStorage(
    String testId,
    int partNumber,
  ) async {
    // Load JSON file từ Firebase Storage
    final jsonData = await FirebaseStorageService.loadJsonData();

    // Navigate JSON: testId → parts → partNumber → questions
    final testData = jsonData[testId];
    if (testData == null) {
      throw Exception('Test $testId not found');
    }

    final parts = testData['parts'] as Map<String, dynamic>?;
    if (parts == null) {
      throw Exception('Parts not found');
    }

    final partData = parts[partNumber.toString()];
    if (partData == null) {
      throw Exception('Part $partNumber not found');
    }

    final questionsData = partData['questions'] as List<dynamic>?;
    if (questionsData == null) {
      throw Exception('Questions not found');
    }

    // Convert từng JSON → ToeicQuestion entity
    final questions = <ToeicQuestion>[];
    for (final q in questionsData) {
      questions.add(
        _mapJsonToQuestion(testId, partNumber, q as Map<String, dynamic>),
      );
    }

    return questions;
  }

  /// Load tất cả 200 questions (Part 1-7)
  static Future<List<ToeicQuestion>> loadAllQuestions(String testId) async {
    final allQuestions = <ToeicQuestion>[];

    for (int part = 1; part <= 7; part++) {
      final partQuestions = await loadQuestionsByPart(testId, part);
      allQuestions.addAll(partQuestions);
    }

    allQuestions.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    return allQuestions;
  }

  /// Convert JSON object → ToeicQuestion entity
  /// Xử lý: images, audio, field mapping
  static ToeicQuestion _mapJsonToQuestion(
    String testId,
    int partNumber,
    Map<String, dynamic> json,
  ) {
    // Handle images: single (imageFile) hoặc multiple (imageFiles)
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

    // Handle audio
    final audioUrl = _getAudioPath(testId, json['audioFile']);

    // Create entity
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

  /// Convert image filename → firebase_image:FILENAME format
  /// (Will be resolved to download URL later)
  static String? _getImagePath(String testId, String? imageFile) {
    if (imageFile == null) return null;
    return 'firebase_image:$imageFile';
  }

  /// Convert audio filename → firebase_audio:FILENAME format
  /// (Will be resolved to download URL later)
  static String? _getAudioPath(String testId, String? audioFile) {
    if (audioFile == null) return null;
    return 'firebase_audio:$audioFile';
  }

  /// Group questions by part
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
}
