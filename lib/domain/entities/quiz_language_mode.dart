// lib/domain/entities/quiz_language_mode.dart

/// Enum định nghĩa chế độ ngôn ngữ cho quiz
/// Xác định hướng câu hỏi và câu trả lời
enum QuizLanguageMode {
  /// Hỏi bằng tiếng Anh, trả lời bằng tiếng Việt
  englishToVietnamese,

  /// Hỏi bằng tiếng Việt, trả lời bằng tiếng Anh
  vietnameseToEnglish,
}

/// Extension methods cho QuizLanguageMode
extension QuizLanguageModeExtension on QuizLanguageMode {
  /// Display text cho UI
  String get displayText {
    switch (this) {
      case QuizLanguageMode.englishToVietnamese:
        return 'Tiếng Anh, Tiếng Việt';
      case QuizLanguageMode.vietnameseToEnglish:
        return 'Tiếng Việt, Tiếng Anh';
    }
  }

  /// Short label cho bottom sheet
  String get shortLabel {
    switch (this) {
      case QuizLanguageMode.englishToVietnamese:
        return 'Tiếng Anh';
      case QuizLanguageMode.vietnameseToEnglish:
        return 'Tiếng Việt';
    }
  }

  /// Description text
  String get description {
    switch (this) {
      case QuizLanguageMode.englishToVietnamese:
        return 'Câu hỏi tiếng Anh → Trả lời tiếng Việt';
      case QuizLanguageMode.vietnameseToEnglish:
        return 'Câu hỏi tiếng Việt → Trả lời tiếng Anh';
    }
  }
}
