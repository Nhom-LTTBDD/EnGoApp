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
  final String? transcript; // Audio transcript
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
    this.transcript,
    required this.order,
    this.groupId,
    this.passageText,
  });

  factory ToeicQuestion.fromJson(Map<String, dynamic> json) {
    return ToeicQuestion(
      id: json['id'] ?? 'q${json['questionNumber']}',
      testId: json['testId'] ?? 'test1',
      partNumber: json['partNumber'] ?? 1,
      questionNumber: json['questionNumber'] ?? 0,
      questionType: json['questionType'] ?? 'multiple-choice',
      questionText: json['questionText'],
      imageUrl: json['imageUrl'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      audioUrl: json['audioUrl'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
      correctAnswer: json['correctAnswer'] ?? 'A',
      explanation: json['explanation'],
      transcript: json['transcript'],
      order: json['order'] ?? json['questionNumber'] ?? 0,
      groupId: json['groupId'],
      passageText: json['passageText'],
    );
  }
}
