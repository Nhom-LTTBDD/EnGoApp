// lib/domain/entities/quiz_config.dart

import 'package:equatable/equatable.dart';
import 'question_type.dart';
import 'quiz_language_mode.dart';

/// Entity chứa cấu hình quiz
/// Immutable data class theo Clean Architecture
class QuizConfig extends Equatable {
  /// ID của topic
  final String topicId;

  /// Tên của topic
  final String topicName;

  /// Tổng số thẻ từ vựng trong topic
  final int totalCards;

  /// Số lượng câu hỏi trong quiz
  final int questionCount;

  /// Loại câu hỏi (Multiple Choice / True-False)
  final QuestionType questionType;

  /// Chế độ ngôn ngữ cho câu hỏi
  final QuizLanguageMode questionLanguage;

  /// Chế độ ngôn ngữ cho câu trả lời
  final QuizLanguageMode answerLanguage;

  const QuizConfig({
    required this.topicId,
    required this.topicName,
    required this.totalCards,
    required this.questionCount,
    required this.questionType,
    required this.questionLanguage,
    required this.answerLanguage,
  });

  /// Factory constructor tạo config mặc định
  factory QuizConfig.defaultConfig({
    required String topicId,
    required String topicName,
    required int totalCards,
  }) {
    return QuizConfig(
      topicId: topicId,
      topicName: topicName,
      totalCards: totalCards,
      questionCount: totalCards,
      questionType: QuestionType.multipleChoice,
      questionLanguage: QuizLanguageMode.englishToVietnamese,
      answerLanguage: QuizLanguageMode.vietnameseToEnglish,
    );
  }

  /// Copy with method cho immutability
  QuizConfig copyWith({
    String? topicId,
    String? topicName,
    int? totalCards,
    int? questionCount,
    QuestionType? questionType,
    QuizLanguageMode? questionLanguage,
    QuizLanguageMode? answerLanguage,
  }) {
    return QuizConfig(
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      totalCards: totalCards ?? this.totalCards,
      questionCount: questionCount ?? this.questionCount,
      questionType: questionType ?? this.questionType,
      questionLanguage: questionLanguage ?? this.questionLanguage,
      answerLanguage: answerLanguage ?? this.answerLanguage,
    );
  }

  @override
  List<Object?> get props => [
    topicId,
    topicName,
    totalCards,
    questionCount,
    questionType,
    questionLanguage,
    answerLanguage,
  ];

  @override
  String toString() {
    return 'QuizConfig(topicId: $topicId, topicName: $topicName, '
        'questionCount: $questionCount/$totalCards, '
        'type: ${questionType.displayName}, '
        'mode: ${answerLanguage.displayText})';
  }
}
