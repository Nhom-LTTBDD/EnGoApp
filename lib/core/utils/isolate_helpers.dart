// lib/core/utils/isolate_helpers.dart
// Helper functions để chạy heavy computation trong isolate (sử dụng compute)

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/entities/vocabulary_card.dart';
import '../../domain/entities/quiz_answer.dart';
import '../../domain/entities/quiz_language_mode.dart';

/// === QUIZ GENERATION HELPERS ===

/// Simple quiz question model for isolate communication
class SimpleQuizQuestion {
  final int questionNumber;
  final String questionText;
  final List<QuizAnswer> answers;
  final String correctCardId;

  SimpleQuizQuestion({
    required this.questionNumber,
    required this.questionText,
    required this.answers,
    required this.correctCardId,
  });
}

class QuizGenerationParams {
  final List<VocabularyCard> cards;
  final int questionCount;
  final int answerCount;
  final QuizLanguageMode languageMode;
  final int randomSeed;

  QuizGenerationParams({
    required this.cards,
    required this.questionCount,
    required this.answerCount,
    required this.languageMode,
    int? randomSeed,
  }) : randomSeed = randomSeed ?? DateTime.now().millisecondsSinceEpoch;
}

class GeneratedQuizData {
  final List<SimpleQuizQuestion> questions;

  GeneratedQuizData(this.questions);
}

/// Hàm chạy trong isolate để generate quiz questions
/// KHÔNG sử dụng BuildContext hay any Flutter UI code
GeneratedQuizData _generateQuizQuestionsIsolate(QuizGenerationParams params) {
  final random = Random(params.randomSeed);
  final shuffledCards = List<VocabularyCard>.from(params.cards)
    ..shuffle(random);

  final questionCount = min(params.questionCount, shuffledCards.length);
  final List<SimpleQuizQuestion> questions = [];

  for (int i = 0; i < questionCount; i++) {
    final correctCard = shuffledCards[i];

    // Generate wrong answers from other cards
    final wrongCards =
        shuffledCards.where((card) => card.id != correctCard.id).toList()
          ..shuffle(random);

    final wrongAnswersCount = params.answerCount - 1;
    final selectedWrongCards = wrongCards.take(wrongAnswersCount).toList();

    // Determine question text and answers based on language mode
    String questionText;
    List<QuizAnswer> answers = [];

    if (params.languageMode == QuizLanguageMode.vietnameseToEnglish) {
      // Hỏi tiếng Việt → Trả lời tiếng Anh
      questionText = correctCard.vietnamese;

      // Correct answer
      answers.add(
        QuizAnswer(
          text: correctCard.english,
          isCorrect: true,
          cardId: correctCard.id,
        ),
      );

      // Wrong answers
      for (var wrongCard in selectedWrongCards) {
        answers.add(
          QuizAnswer(
            text: wrongCard.english,
            isCorrect: false,
            cardId: wrongCard.id,
          ),
        );
      }
    } else {
      // Hỏi tiếng Anh → Trả lời tiếng Việt
      questionText = correctCard.english;

      // Correct answer
      answers.add(
        QuizAnswer(
          text: correctCard.vietnamese,
          isCorrect: true,
          cardId: correctCard.id,
        ),
      );

      // Wrong answers
      for (var wrongCard in selectedWrongCards) {
        answers.add(
          QuizAnswer(
            text: wrongCard.vietnamese,
            isCorrect: false,
            cardId: wrongCard.id,
          ),
        );
      }
    }

    // Shuffle answers
    answers.shuffle(random);

    questions.add(
      SimpleQuizQuestion(
        questionNumber: i + 1,
        questionText: questionText,
        answers: answers,
        correctCardId: correctCard.id,
      ),
    );
  }

  return GeneratedQuizData(questions);
}

/// Public function để gọi từ UI - sử dụng compute
Future<List<SimpleQuizQuestion>> generateQuizQuestions({
  required List<VocabularyCard> cards,
  required int questionCount,
  required int answerCount,
  required QuizLanguageMode languageMode,
}) async {
  if (cards.length < answerCount) {
    debugPrint(
      '[QUIZ ISOLATE] Not enough cards (need $answerCount, got ${cards.length})',
    );
    return [];
  }

  final params = QuizGenerationParams(
    cards: cards,
    questionCount: questionCount,
    answerCount: answerCount,
    languageMode: languageMode,
  );

  // Chạy trong isolate bằng compute
  final result = await compute(_generateQuizQuestionsIsolate, params);
  return result.questions;
}

/// === TOPIC GROUPING HELPERS ===

class TopicGroupingParams {
  final List<VocabularyCard> cards;

  TopicGroupingParams(this.cards);
}

class GroupedTopicData {
  final Map<String, int> cardsByTopic;

  GroupedTopicData(this.cardsByTopic);
}

/// Extract topic ID from card ID (e.g., "food_1" -> "food")
String? _extractTopicId(String cardId) {
  if (cardId.contains('_')) {
    return cardId.split('_').first;
  }
  return null;
}

/// Hàm chạy trong isolate để group cards by topic
GroupedTopicData _groupCardsByTopicIsolate(TopicGroupingParams params) {
  final cardsByTopic = <String, int>{};

  for (final card in params.cards) {
    // Extract topic ID from card ID (format: topicId_number)
    final topicId = _extractTopicId(card.id);
    if (topicId != null) {
      cardsByTopic[topicId] = (cardsByTopic[topicId] ?? 0) + 1;
    }
  }

  // Sort by card count (descending)
  final sortedEntries = cardsByTopic.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return GroupedTopicData(Map.fromEntries(sortedEntries));
}

/// Public function để group cards by topic - sử dụng compute
Future<Map<String, int>> groupCardsByTopic(List<VocabularyCard> cards) async {
  if (cards.isEmpty) {
    return {};
  }

  final params = TopicGroupingParams(cards);

  // Chạy trong isolate bằng compute
  final result = await compute(_groupCardsByTopicIsolate, params);
  return result.cardsByTopic;
}

/// === VOCABULARY FILTERING HELPERS ===

class VocabularyFilterParams {
  final List<VocabularyCard> cards;
  final String topicId;

  VocabularyFilterParams({required this.cards, required this.topicId});
}

class FilteredVocabularyData {
  final List<VocabularyCard> filteredCards;

  FilteredVocabularyData(this.filteredCards);
}

/// Hàm chạy trong isolate để filter cards by topic
FilteredVocabularyData _filterCardsByTopicIsolate(
  VocabularyFilterParams params,
) {
  final filtered = params.cards.where((card) {
    final topicId = _extractTopicId(card.id);
    return topicId == params.topicId;
  }).toList();

  return FilteredVocabularyData(filtered);
}

/// Public function để filter cards by topic - sử dụng compute
Future<List<VocabularyCard>> filterCardsByTopic({
  required List<VocabularyCard> cards,
  required String topicId,
}) async {
  if (cards.isEmpty) {
    return [];
  }

  final params = VocabularyFilterParams(cards: cards, topicId: topicId);

  // Chạy trong isolate bằng compute
  final result = await compute(_filterCardsByTopicIsolate, params);
  return result.filteredCards;
}

/// === TEST SCORING HELPERS ===

class TestScoringParams {
  final List<Map<String, dynamic>> questions; // Serializable question data
  final Map<int, String> userAnswers;

  TestScoringParams({required this.questions, required this.userAnswers});
}

class TestScoreData {
  final int totalCorrect;
  final int totalWrong;
  final int totalUnanswered;
  final int listeningCorrect;
  final int listeningWrong;
  final int listeningUnanswered;
  final int readingCorrect;
  final int readingWrong;
  final int readingUnanswered;
  final Map<String, dynamic> partScores;

  TestScoreData({
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalUnanswered,
    required this.listeningCorrect,
    required this.listeningWrong,
    required this.listeningUnanswered,
    required this.readingCorrect,
    required this.readingWrong,
    required this.readingUnanswered,
    required this.partScores,
  });
}

/// Hàm chạy trong isolate để calculate test score
TestScoreData _calculateTestScoreIsolate(TestScoringParams params) {
  // Separate listening and reading questions
  final listeningQuestions = params.questions
      .where((q) => (q['partNumber'] as int) <= 4)
      .toList();
  final readingQuestions = params.questions
      .where((q) => (q['partNumber'] as int) >= 5)
      .toList();

  // Calculate stats for each section
  int listeningCorrect = 0;
  int listeningWrong = 0;
  int listeningUnanswered = 0;

  int readingCorrect = 0;
  int readingWrong = 0;
  int readingUnanswered = 0;

  // Count listening results
  for (final question in listeningQuestions) {
    final questionNumber = question['questionNumber'] as int;
    final correctAnswer = question['correctAnswer'] as String;
    final userAnswer = params.userAnswers[questionNumber];

    if (userAnswer == null || userAnswer.isEmpty) {
      listeningUnanswered++;
    } else if (userAnswer == correctAnswer) {
      listeningCorrect++;
    } else {
      listeningWrong++;
    }
  }

  // Count reading results
  for (final question in readingQuestions) {
    final questionNumber = question['questionNumber'] as int;
    final correctAnswer = question['correctAnswer'] as String;
    final userAnswer = params.userAnswers[questionNumber];

    if (userAnswer == null || userAnswer.isEmpty) {
      readingUnanswered++;
    } else if (userAnswer == correctAnswer) {
      readingCorrect++;
    } else {
      readingWrong++;
    }
  }

  // Calculate part scores
  final partScores = <String, dynamic>{};
  for (int part = 1; part <= 7; part++) {
    final partQuestions = params.questions
        .where((q) => (q['partNumber'] as int) == part)
        .toList();

    int partCorrect = 0;
    for (final question in partQuestions) {
      final questionNumber = question['questionNumber'] as int;
      final correctAnswer = question['correctAnswer'] as String;
      final userAnswer = params.userAnswers[questionNumber];

      if (userAnswer == correctAnswer) {
        partCorrect++;
      }
    }

    partScores['part$part'] = {
      'correct': partCorrect,
      'total': partQuestions.length,
      'percentage': partQuestions.isEmpty
          ? 0.0
          : (partCorrect / partQuestions.length) * 100,
    };
  }

  return TestScoreData(
    totalCorrect: listeningCorrect + readingCorrect,
    totalWrong: listeningWrong + readingWrong,
    totalUnanswered: listeningUnanswered + readingUnanswered,
    listeningCorrect: listeningCorrect,
    listeningWrong: listeningWrong,
    listeningUnanswered: listeningUnanswered,
    readingCorrect: readingCorrect,
    readingWrong: readingWrong,
    readingUnanswered: readingUnanswered,
    partScores: partScores,
  );
}

/// Public function để calculate test score - sử dụng compute
Future<TestScoreData> calculateTestScore({
  required List<Map<String, dynamic>> questions,
  required Map<int, String> userAnswers,
}) async {
  final params = TestScoringParams(
    questions: questions,
    userAnswers: userAnswers,
  );

  // Chạy trong isolate bằng compute
  return await compute(_calculateTestScoreIsolate, params);
}

/// === TOEIC QUESTION GROUP HELPERS ===

class QuestionGroupParams {
  final List<Map<String, dynamic>> questions; // Serializable questions
  final int currentPartNumber;
  final String? currentGroupId;

  QuestionGroupParams({
    required this.questions,
    required this.currentPartNumber,
    this.currentGroupId,
  });
}

class GroupedQuestionsData {
  final List<Map<String, dynamic>> groupQuestions;
  final int lastQuestionIndex;

  GroupedQuestionsData({
    required this.groupQuestions,
    required this.lastQuestionIndex,
  });
}

/// Hàm chạy trong isolate để find và sort questions trong group
GroupedQuestionsData _findQuestionGroupIsolate(QuestionGroupParams params) {
  // Find all questions in current group
  final groupQuestions =
      params.questions.where((q) {
        return q['partNumber'] == params.currentPartNumber &&
            q['groupId'] == params.currentGroupId;
      }).toList()..sort(
        (a, b) =>
            (a['questionNumber'] as int).compareTo(b['questionNumber'] as int),
      );

  int lastQuestionIndex = -1;
  if (groupQuestions.isNotEmpty) {
    final lastQuestion = groupQuestions.last;
    lastQuestionIndex = params.questions.indexWhere(
      (q) => q['questionNumber'] == lastQuestion['questionNumber'],
    );
  }

  return GroupedQuestionsData(
    groupQuestions: groupQuestions,
    lastQuestionIndex: lastQuestionIndex,
  );
}

/// Public function để find question group - sử dụng compute
Future<GroupedQuestionsData> findQuestionGroup({
  required List<Map<String, dynamic>> questions,
  required int currentPartNumber,
  String? currentGroupId,
}) async {
  final params = QuestionGroupParams(
    questions: questions,
    currentPartNumber: currentPartNumber,
    currentGroupId: currentGroupId,
  );

  // Chạy trong isolate bằng compute
  return await compute(_findQuestionGroupIsolate, params);
}

/// === TEST HISTORY CALCULATION HELPERS ===

class TestHistoryParams {
  final List<Map<String, dynamic>> questions;
  final Map<int, String> userAnswers;

  TestHistoryParams({required this.questions, required this.userAnswers});
}

class TestHistoryData {
  final List<int> incorrectQuestions;
  final Map<int, String> correctAnswersMap;
  final Map<String, dynamic> partScores;

  TestHistoryData({
    required this.incorrectQuestions,
    required this.correctAnswersMap,
    required this.partScores,
  });
}

/// Hàm chạy trong isolate để calculate test history data
TestHistoryData _calculateTestHistoryIsolate(TestHistoryParams params) {
  final incorrectQuestions = <int>[];
  final correctAnswersMap = <int, String>{};

  // Calculate incorrect questions
  for (final question in params.questions) {
    final questionNumber = question['questionNumber'] as int;
    final correctAnswer = question['correctAnswer'] as String;
    correctAnswersMap[questionNumber] = correctAnswer;

    final userAnswer = params.userAnswers[questionNumber] ?? '';
    if (userAnswer != correctAnswer) {
      incorrectQuestions.add(questionNumber);
    }
  }

  // Calculate part scores
  final partScores = <String, dynamic>{};
  for (int part = 1; part <= 7; part++) {
    final partQuestions = params.questions
        .where((q) => (q['partNumber'] as int) == part)
        .toList();

    int partCorrect = 0;
    for (final question in partQuestions) {
      final questionNumber = question['questionNumber'] as int;
      final correctAnswer = question['correctAnswer'] as String;
      final userAnswer = params.userAnswers[questionNumber];

      if (userAnswer == correctAnswer) {
        partCorrect++;
      }
    }

    partScores['part$part'] = {
      'correct': partCorrect,
      'total': partQuestions.length,
      'percentage': partQuestions.isEmpty
          ? 0.0
          : (partCorrect / partQuestions.length) * 100,
    };
  }

  return TestHistoryData(
    incorrectQuestions: incorrectQuestions,
    correctAnswersMap: correctAnswersMap,
    partScores: partScores,
  );
}

/// Public function để calculate test history - sử dụng compute
Future<TestHistoryData> calculateTestHistory({
  required List<Map<String, dynamic>> questions,
  required Map<int, String> userAnswers,
}) async {
  final params = TestHistoryParams(
    questions: questions,
    userAnswers: userAnswers,
  );

  // Chạy trong isolate bằng compute
  return await compute(_calculateTestHistoryIsolate, params);
}
