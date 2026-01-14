// lib/data/datasources/toeic_sample_data.dart
// Sample TOEIC data với 31 questions từ audio files có sẵn

import '../../domain/entities/toeic_test.dart';
import '../../domain/entities/toeic_question.dart';

class ToeicSampleData {
  static ToeicTest get practiceTest1 => ToeicTest(
    id: 'test1',
    name: 'TOEIC Practice Test 1',
    description: 'Complete TOEIC practice test with 31 listening questions',
    totalQuestions: 31,
    listeningQuestions: 31,
    readingQuestions: 0,
    duration: 45, // minutes
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
    year: 2026,
  );

  static List<ToeicQuestion> get questions => List.generate(31, (index) {
    final questionNum = index + 1;
    final questionId = 'test1_q${questionNum.toString().padLeft(3, '0')}';
    final audioFileName = '${questionNum.toString().padLeft(3, '0')}.mp3';
    
    return ToeicQuestion(
      id: questionId,
      testId: 'test1',
      partNumber: _getPartNumber(questionNum),
      questionNumber: questionNum,
      questionType: 'single',
      questionText: _getQuestionText(questionNum),
      audioUrl: 'assets/audio/toeic_test1/$audioFileName',
      options: _getOptions(questionNum),
      correctAnswer: _getCorrectAnswer(questionNum),
      explanation: 'Explanation for question $questionNum',
      order: questionNum,
    );
  });

  static int _getPartNumber(int questionNum) {
    if (questionNum <= 6) return 1;  // Part 1: Photos
    if (questionNum <= 31) return 2; // Part 2: Question-Response
    return 2;
  }

  static String _getQuestionText(int questionNum) {
    if (questionNum <= 6) {
      return 'Look at the picture and listen to the four statements. Choose the statement that best describes what you see.';
    } else {
      return 'You will hear a question or statement and three responses. Choose the best response.';
    }
  }

  static List<String> _getOptions(int questionNum) {
    final base = (questionNum % 4) + 1;
    return [
      'Option A - Response ${base}A',
      'Option B - Response ${base}B', 
      'Option C - Response ${base}C',
      'Option D - Response ${base}D',
    ];
  }

  static String _getCorrectAnswer(int questionNum) {
    const answers = ['A', 'B', 'C', 'D'];
    return answers[questionNum % 4];
  }
}