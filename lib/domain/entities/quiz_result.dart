// lib/domain/entities/quiz_result.dart

import 'package:equatable/equatable.dart';

/// Entity đại diện cho kết quả của một câu hỏi
class QuestionResult extends Equatable {
  /// Text câu hỏi
  final String questionText;

  /// Đáp án đúng
  final String correctAnswer;

  /// Đáp án người dùng chọn
  final String userAnswer;

  /// Người dùng trả lời đúng?
  final bool isCorrect;

  const QuestionResult({
    required this.questionText,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [
    questionText,
    correctAnswer,
    userAnswer,
    isCorrect,
  ];
}

/// Entity đại diện cho kết quả tổng thể của quiz
class QuizResult extends Equatable {
  /// ID của topic
  final String topicId;

  /// Tên topic
  final String topicName;

  /// Tổng số câu hỏi
  final int totalQuestions;

  /// Số câu trả lời đúng
  final int correctAnswers;

  /// Số câu trả lời sai
  final int wrongAnswers;

  /// Danh sách kết quả từng câu
  final List<QuestionResult> questionResults;

  const QuizResult({
    required this.topicId,
    required this.topicName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.questionResults,
  });

  /// Tính % điểm
  int get scorePercentage {
    if (totalQuestions == 0) return 0;
    return ((correctAnswers / totalQuestions) * 100).round();
  }

  /// Kiểm tra pass (>= 60%)
  bool get isPassed => scorePercentage >= 60;

  @override
  List<Object?> get props => [
    topicId,
    topicName,
    totalQuestions,
    correctAnswers,
    wrongAnswers,
    questionResults,
  ];

  @override
  String toString() {
    return 'QuizResult(topic: $topicName, score: $correctAnswers/$totalQuestions = $scorePercentage%)';
  }
}
