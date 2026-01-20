// lib/domain/entities/quiz_answer.dart

/// Entity đại diện cho một đáp án trong quiz
class QuizAnswer {
  /// Text của đáp án
  final String text;

  /// Đáp án này có đúng không
  final bool isCorrect;

  /// ID của card tương ứng (để tham chiếu)
  final String cardId;

  const QuizAnswer({
    required this.text,
    required this.isCorrect,
    required this.cardId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAnswer &&
        other.text == text &&
        other.isCorrect == isCorrect &&
        other.cardId == cardId;
  }

  @override
  int get hashCode => text.hashCode ^ isCorrect.hashCode ^ cardId.hashCode;

  @override
  String toString() {
    return 'QuizAnswer(text: $text, isCorrect: $isCorrect, cardId: $cardId)';
  }
}
