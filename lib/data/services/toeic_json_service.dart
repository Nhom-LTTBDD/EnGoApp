// lib/data/services/toeic_json_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';

class ToeicJsonService {
  static Future<Map<String, dynamic>> loadJsonData() async {
    try {
      print('Loading JSON from assets/toeic_questions.json...');
      String jsonString = await rootBundle.loadString(
        'assets/toeic_questions.json',
      );
      print('Raw JSON string length: ${jsonString.length}');
      final data = json.decode(jsonString);
      print('JSON decoded successfully');
      print('Available tests: ${data.keys.toList()}');

      // Check if test1 exists
      if (data['test1'] != null) {
        final test1 = data['test1'];
        print('Test1 found with keys: ${test1.keys.toList()}');
        if (test1['parts'] != null) {
          final parts = test1['parts'];
          print('Available parts: ${parts.keys.toList()}');
        }
      }

      return data;
    } catch (e) {
      print('Error loading JSON: $e');
      print('Error type: ${e.runtimeType}');
      return {};
    }
  }

  static Future<ToeicTest> loadTest(String testId) async {
    final data = await loadJsonData();
    final testData = data[testId];

    if (testData == null) {
      throw Exception('Test $testId not found');
    }

    return ToeicTest(
      id: testId,
      name: testData['name'],
      description: 'TOEIC Practice Test',
      totalQuestions: testData['totalQuestions'],
      listeningQuestions: 100, // Part 1-4
      readingQuestions: 100, // Part 5-7
      duration: testData['duration'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      year: 2025,
    );
  }

  static Future<List<ToeicQuestion>> loadQuestionsByPart(
    String testId,
    int partNumber,
  ) async {
    try {
      print('Loading questions for test: $testId, part: $partNumber');
      final data = await loadJsonData();

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
          final imageUrl = _getImagePath(questionData['imageFile']);
          final audioUrl = _getAudioPath(questionData['audioFile']);

          print(
            'Question ${questionData['questionNumber']}: imageFile=${questionData['imageFile']}, imageUrl=$imageUrl',
          );

          final question = ToeicQuestion(
            id: 'q${questionData['questionNumber']}',
            testId: testId,
            partNumber: partNumber,
            questionNumber: questionData['questionNumber'],
            questionType: questionData['questionType'] ?? 'multiple-choice',
            questionText: questionData['questionText'],
            imageUrl: imageUrl,
            audioUrl: audioUrl,
            options: List<String>.from(questionData['options'] ?? []),
            correctAnswer: questionData['correctAnswer'] ?? 'A',
            explanation: questionData['explanation'] ?? '',
            order: questionData['questionNumber'],
            groupId: questionData['groupId'],
            passageText: questionData['audioTranscript'],
          );
          questions.add(question);
        } catch (e) {
          print('Error creating question: $e');
        }
      }

      print('Successfully created ${questions.length} ToeicQuestion objects');
      return questions;
    } catch (e) {
      print('Error loading questions for part $partNumber: $e');
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
