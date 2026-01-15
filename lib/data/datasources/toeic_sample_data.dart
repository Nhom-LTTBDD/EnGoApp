// lib/data/datasources/toeic_sample_data.dart

import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';
import '../services/toeic_json_service.dart';

class ToeicSampleData {
  // Load test information from JSON
  static Future<ToeicTest> getPracticeTest1() async {
    try {
      return await ToeicJsonService.loadTest('test1');
    } catch (e) {
      print('Error loading test: $e');
      // Fallback test info
      return ToeicTest(
        id: 'test1',
        name: 'TOEIC Practice Test 1',
        description: 'Complete TOEIC practice test with 7 parts',
        totalQuestions: 100,
        listeningQuestions: 70, // Part 1-4
        readingQuestions: 30, // Part 5-7
        duration: 120, // 120 minutes
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        year: 2025,
      );
    }
  }

  // Static fallback for immediate access (will be replaced by async method above)
  static final ToeicTest practiceTest1 = ToeicTest(
    id: 'test1',
    name: 'TOEIC Practice Test 1',
    description: 'Complete TOEIC practice test with 7 parts',
    totalQuestions: 100,
    listeningQuestions: 70, // Part 1-4
    readingQuestions: 30, // Part 5-7
    duration: 120, // 120 minutes
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
    year: 2025,
  );

  // Part definitions for navigation
  static final List<Map<String, dynamic>> parts = [
    {'number': 1, 'name': 'Part 1', 'questionCount': 6, 'type': 'Photographs'},
    {
      'number': 2,
      'name': 'Part 2',
      'questionCount': 25,
      'type': 'Question-Response',
    },
    {
      'number': 3,
      'name': 'Part 3',
      'questionCount': 39,
      'type': 'Conversations',
    },
    {'number': 4, 'name': 'Part 4', 'questionCount': 30, 'type': 'Talks'},
    {
      'number': 5,
      'name': 'Part 5',
      'questionCount': 30,
      'type': 'Incomplete Sentences',
    },
    {
      'number': 6,
      'name': 'Part 6',
      'questionCount': 16,
      'type': 'Text Completion',
    },
    {
      'number': 7,
      'name': 'Part 7',
      'questionCount': 54,
      'type': 'Reading Comprehension',
    },
  ];

  // Load questions from JSON for specific part
  static Future<List<ToeicQuestion>> getQuestionsByPart(int partNumber) async {
    try {
      print('ToeicSampleData: Loading questions for part $partNumber');
      final questions = await ToeicJsonService.loadQuestionsByPart(
        'test1',
        partNumber,
      );
      print('ToeicSampleData: Loaded ${questions.length} questions from JSON');
      
      if (questions.isNotEmpty) {
        return questions;
      }
      
      // Fallback: create some sample questions if JSON is empty
      print('ToeicSampleData: No questions from JSON, creating fallback');
      return _createFallbackQuestions(partNumber);
    } catch (e) {
      print('Error loading questions for part $partNumber: $e');
      // Return fallback questions on error
      return _createFallbackQuestions(partNumber);
    }
  }

  // Create fallback questions when JSON loading fails
  static List<ToeicQuestion> _createFallbackQuestions(int partNumber) {
    print('Creating fallback questions for part $partNumber');
    return List.generate(3, (index) {
      final questionNumber = index + 1;
      return ToeicQuestion(
        id: 'fallback_part${partNumber}_q$questionNumber',
        testId: 'test1',
        partNumber: partNumber,
        questionNumber: questionNumber,
        questionType: partNumber <= 2 ? 'image-audio' : 'multiple-choice',
        questionText: partNumber <= 2 ? null : 'Sample question $questionNumber for Part $partNumber',
        imageUrl: partNumber == 1 ? 'assets/test_toeic/test_1/test1_$questionNumber.png' : null,
        audioUrl: partNumber <= 4 ? 'assets/audio/toeic_test1/${questionNumber.toString().padLeft(3, '0')}.mp3' : null,
        options: partNumber <= 2 ? ['A', 'B', 'C', 'D'] : [
          'Option A for question $questionNumber',
          'Option B for question $questionNumber',  
          'Option C for question $questionNumber',
          'Option D for question $questionNumber',
        ],
        correctAnswer: 'A',
        explanation: 'This is a fallback sample question.',
        order: questionNumber,
        groupId: null,
        passageText: null,
      );
    });
  }

  // Load all questions from JSON
  static Future<List<ToeicQuestion>> getAllQuestions() async {
    try {
      return await ToeicJsonService.loadAllQuestions('test1');
    } catch (e) {
      print('Error loading all questions: $e');
      return [];
    }
  }
}
