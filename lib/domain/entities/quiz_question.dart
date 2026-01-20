// lib/domain/entities/quiz_question.dart

import 'quiz_answer.dart';
import 'vocabulary_card.dart';

/// Entity đại diện cho một câu hỏi trong quiz
class QuizQuestion {
  /// Text của câu hỏi
  final String questionText;

  /// Card gốc chứa câu trả lời đúng
  final VocabularyCard correctCard;

  /// Danh sách các đáp án (đã shuffle)
  final List<QuizAnswer> answers;

  /// Index của câu hỏi (1-based)
  final int questionNumber;

  const QuizQuestion({
    required this.questionText,
    required this.correctCard,
    required this.answers,
    required this.questionNumber,
  });

  /// Lấy đáp án đúng
  QuizAnswer get correctAnswer =>
      answers.firstWhere((answer) => answer.isCorrect);

  @override
  String toString() {
    return 'QuizQuestion(#$questionNumber: $questionText, ${answers.length} answers)';
  }
}
