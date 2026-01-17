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
      throw Exception('Failed to load TOEIC test data: $e');
    }
  }

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

      if (questions.isEmpty) {
        throw Exception('No questions found for part $partNumber in JSON data');
      }

      return questions;
    } catch (e) {
      print('Error loading questions for part $partNumber: $e');
      throw Exception('Failed to load questions for part $partNumber: $e');
    }
  }

  // Load all questions from JSON
  static Future<List<ToeicQuestion>> getAllQuestions() async {
    try {
      final questions = await ToeicJsonService.loadAllQuestions('test1');
      if (questions.isEmpty) {
        throw Exception('No questions found in JSON data');
      }
      return questions;
    } catch (e) {
      print('Error loading all questions: $e');
      throw Exception('Failed to load TOEIC questions: $e');
    }
  }
}
