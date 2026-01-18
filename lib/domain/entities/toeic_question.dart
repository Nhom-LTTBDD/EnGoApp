// lib/domain/entities/toeic_question.dart

class ToeicQuestion {
  final String id;
  final String testId;
  final int partNumber;
  final int questionNumber;
  final String questionType; // 'single', 'group', 'image'
  final String? questionText;
  final String? imageUrl;
  final List<String>? imageUrls; // For multiple images in a group
  final String? audioUrl;
  final List<String> options; // A, B, C, D
  final String correctAnswer;
  final String? explanation;
  final int order;

  final String? groupId;
  final String? passageText;

  const ToeicQuestion({
    required this.id,
    required this.testId,
    required this.partNumber,
    required this.questionNumber,
    required this.questionType,
    this.questionText,
    this.imageUrl,
    this.imageUrls,
    this.audioUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.order,
    this.groupId,
    this.passageText,
  });
}
