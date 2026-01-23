// lib/domain/entities/question_type.dart

/// Enum định nghĩa loại câu hỏi trong quiz
enum QuestionType {
  /// Câu hỏi nhiều lựa chọn (4 đáp án)
  multipleChoice,

  /// Câu hỏi đúng/sai (2 đáp án)
  trueFalse,
}

/// Extension methods cho QuestionType
extension QuestionTypeExtension on QuestionType {
  /// Display name cho UI
  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Nhiều lựa chọn';
      case QuestionType.trueFalse:
        return 'Đúng / Sai';
    }
  }

  /// Số lượng đáp án cho mỗi loại câu hỏi
  int get answerCount {
    switch (this) {
      case QuestionType.multipleChoice:
        return 4;
      case QuestionType.trueFalse:
        return 2;
    }
  }
}
