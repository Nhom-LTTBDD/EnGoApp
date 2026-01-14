// lib/data/models/toeic_question_model.dart

import '../../domain/entities/toeic_question.dart';

class ToeicQuestionModel {
  final String id;
  final String testId;
  final int partNumber;
  final int questionNumber;
  final String questionType;
  final String? questionText;
  final String? imageUrl;
  final String? audioUrl;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int order;
  final String? groupId;
  final String? passageText;

  const ToeicQuestionModel({
    required this.id,
    required this.testId,
    required this.partNumber,
    required this.questionNumber,
    required this.questionType,
    this.questionText,
    this.imageUrl,
    this.audioUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.order,
    this.groupId,
    this.passageText,
  });

  factory ToeicQuestionModel.fromJson(Map<String, dynamic> json) {
    return ToeicQuestionModel(
      id: json['id'] as String? ?? '',
      testId: json['testId'] as String? ?? '',
      partNumber: json['partNumber'] as int? ?? 1,
      questionNumber: json['questionNumber'] as int? ?? 0,
      questionType: json['questionType'] as String? ?? 'single',
      questionText: json['questionText'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String?,
      order: json['order'] as int? ?? 0,
      groupId: json['groupId'] as String?,
      passageText: json['passageText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'partNumber': partNumber,
      'questionNumber': questionNumber,
      'questionType': questionType,
      'questionText': questionText,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'order': order,
      'groupId': groupId,
      'passageText': passageText,
    };
  }

  factory ToeicQuestionModel.fromEntity(ToeicQuestion entity) {
    return ToeicQuestionModel(
      id: entity.id,
      testId: entity.testId,
      partNumber: entity.partNumber,
      questionNumber: entity.questionNumber,
      questionType: entity.questionType,
      questionText: entity.questionText,
      imageUrl: entity.imageUrl,
      audioUrl: entity.audioUrl,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      explanation: entity.explanation,
      order: entity.order,
      groupId: entity.groupId,
      passageText: entity.passageText,
    );
  }

  ToeicQuestion toEntity() {
    return ToeicQuestion(
      id: id,
      testId: testId,
      partNumber: partNumber,
      questionNumber: questionNumber,
      questionType: questionType,
      questionText: questionText,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      options: options,
      correctAnswer: correctAnswer,
      explanation: explanation,
      order: order,
      groupId: groupId,
      passageText: passageText,
    );
  }

  ToeicQuestionModel copyWith({
    String? id,
    String? testId,
    int? partNumber,
    int? questionNumber,
    String? questionType,
    String? questionText,
    String? imageUrl,
    String? audioUrl,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    int? order,
    String? groupId,
    String? passageText,
  }) {
    return ToeicQuestionModel(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      partNumber: partNumber ?? this.partNumber,
      questionNumber: questionNumber ?? this.questionNumber,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      order: order ?? this.order,
      groupId: groupId ?? this.groupId,
      passageText: passageText ?? this.passageText,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ToeicQuestionModel &&
        other.id == id &&
        other.testId == testId &&
        other.partNumber == partNumber &&
        other.questionNumber == questionNumber &&
        other.questionType == questionType &&
        other.questionText == questionText &&
        other.imageUrl == imageUrl &&
        other.audioUrl == audioUrl &&
        other.options == options &&
        other.correctAnswer == correctAnswer &&
        other.explanation == explanation &&
        other.order == order &&
        other.groupId == groupId &&
        other.passageText == passageText;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        testId.hashCode ^
        partNumber.hashCode ^
        questionNumber.hashCode ^
        questionType.hashCode ^
        questionText.hashCode ^
        imageUrl.hashCode ^
        audioUrl.hashCode ^
        options.hashCode ^
        correctAnswer.hashCode ^
        explanation.hashCode ^
        order.hashCode ^
        groupId.hashCode ^
        passageText.hashCode;
  }

  @override
  String toString() {
    return 'ToeicQuestionModel(id: $id, testId: $testId, partNumber: $partNumber, questionNumber: $questionNumber, questionType: $questionType, questionText: $questionText, imageUrl: $imageUrl, audioUrl: $audioUrl, options: $options, correctAnswer: $correctAnswer, explanation: $explanation, order: $order, groupId: $groupId, passageText: $passageText)';
  }
}
