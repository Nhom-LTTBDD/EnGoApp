// lib/presentation/pages/vocabulary/quiz_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../domain/entities/quiz_config.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../../domain/entities/quiz_answer.dart';
import '../../../domain/entities/quiz_result.dart';
import '../../../domain/entities/quiz_language_mode.dart';
import '../../../domain/entities/vocabulary_card.dart';
import '../../../domain/entities/question_type.dart';
import '../../../data/repositories/vocabulary_repository_impl.dart';
import '../../../routes/app_routes.dart';

/// Page làm quiz theo topic
class QuizPage extends StatefulWidget {
  final QuizConfig config;

  const QuizPage({super.key, required this.config});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  List<QuizQuestion> _questions = [];
  final List<QuestionResult> _questionResults = [];
  bool _hasAnswered = false;
  final _repository = VocabularyRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  void _loadQuizData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        debugPrint('[QUIZ] Loading cards for topic: ${widget.config.topicId}');

        final cards = await _repository.getVocabularyCards(
          widget.config.topicId,
        );

        if (mounted && cards.isNotEmpty) {
          debugPrint(
            '[QUIZ] Loaded ${cards.length} cards, generating questions...',
          );
          _generateQuestions(cards);
        } else {
          debugPrint('[QUIZ] Cannot generate - cards empty or unmounted');
        }
      } catch (e) {
        debugPrint('[QUIZ] Error: $e');
      }
    });
  }

  /// Generate quiz questions from vocabulary cards
  void _generateQuestions(List<VocabularyCard> cards) {
    if (cards.length < 4) {
      debugPrint('[QUIZ] Not enough cards (need 4, got ${cards.length})');
      return;
    }

    final random = Random();
    final shuffledCards = List<VocabularyCard>.from(cards)..shuffle(random);
    final questionCount = min(
      widget.config.questionCount,
      shuffledCards.length,
    );

    final List<QuizQuestion> questions = [];

    for (int i = 0; i < questionCount; i++) {
      final correctCard = shuffledCards[i];

      // Generate wrong answers from other cards
      final wrongCards =
          shuffledCards.where((card) => card.id != correctCard.id).toList()
            ..shuffle(random);

      final wrongAnswersCount = widget.config.questionType.answerCount - 1;
      final selectedWrongCards = wrongCards.take(wrongAnswersCount).toList();

      // Determine question text and answers based on language mode
      String questionText;
      List<QuizAnswer> answers = [];

      if (widget.config.answerLanguage ==
          QuizLanguageMode.vietnameseToEnglish) {
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
        QuizQuestion(
          questionText: questionText,
          correctCard: correctCard,
          answers: answers,
          questionNumber: i + 1,
        ),
      );
    }

    // Update state
    if (mounted) {
      debugPrint('[QUIZ] Generated ${questions.length} questions');
      setState(() {
        _questions = questions;
      });
    }
  }

  /// Handle answer selection
  void _handleAnswerTap(QuizAnswer answer) {
    if (_hasAnswered) return; // Prevent multiple answers

    setState(() {
      _hasAnswered = true;

      final currentQuestion = _questions[_currentQuestionIndex];

      if (answer.isCorrect) {
        _correctAnswers++;
      } else {
        _wrongAnswers++;
      }

      // Record result
      _questionResults.add(
        QuestionResult(
          questionText: currentQuestion.questionText,
          correctAnswer: currentQuestion.correctAnswer.text,
          userAnswer: answer.text,
          isCorrect: answer.isCorrect,
        ),
      );
    });

    // Auto move to next question or show result
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        _nextQuestion();
      } else {
        _showResult();
      }
    });
  }

  /// Move to next question
  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _hasAnswered = false;
    });
  }

  /// Show quiz result
  void _showResult() {
    final result = QuizResult(
      topicId: widget.config.topicId,
      topicName: widget.config.topicName,
      totalQuestions: _questions.length,
      correctAnswers: _correctAnswers,
      wrongAnswers: _wrongAnswers,
      questionResults: _questionResults,
    );

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.quizResult,
      arguments: {'result': result},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'QUIZ: ${widget.config.topicName.toUpperCase()}',
      currentIndex: -1,
      showBottomNav: false,
      child: _questions.isEmpty
          ? _buildLoadingState()
          : Container(
              decoration: BoxDecoration(color: getBackgroundColor(context)),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(spaceMd),
                  child: Column(
                    children: [
                      // Progress indicator
                      _buildProgressIndicator(_questions.length),
                      const SizedBox(height: spaceLg),

                      // Question card
                      Expanded(
                        child: _buildQuestionCard(
                          _questions[_currentQuestionIndex],
                        ),
                      ),
                      const SizedBox(height: spaceLg),

                      // Answer options
                      _buildAnswerOptions(_questions[_currentQuestionIndex]),
                      const SizedBox(height: spaceMd),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: spaceMd),
          Text('Đang tải câu hỏi...'),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int totalQuestions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: getTextPrimary(context)),
        ),
        Text(
          'Câu ${_currentQuestionIndex + 1} / $totalQuestions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: getTextPrimary(context),
          ),
        ),
        const SizedBox(width: 48), // Placeholder for balance
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    // Determine label based on language mode
    String label;
    if (widget.config.answerLanguage == QuizLanguageMode.vietnameseToEnglish) {
      label = 'Chọn câu trả lời';
    } else {
      label = 'Nghĩa của thuật ngữ';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(spaceLg),
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: getTextPrimary(context).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Thuật ngữ',
            style: TextStyle(fontSize: 14, color: getTextThird(context)),
          ),
          const SizedBox(height: spaceMd),
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: getTextPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spaceLg),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: getTextThird(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(QuizQuestion question) {
    return Column(
      children: question.answers.map((answer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: spaceSm),
          child: _buildAnswerButton(answer),
        );
      }).toList(),
    );
  }

  Widget _buildAnswerButton(QuizAnswer answer) {
    final showResult = _hasAnswered;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: showResult ? null : () => _handleAnswerTap(answer),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          backgroundColor: getSurfaceColor(context),
          foregroundColor: getTextPrimary(context),
          disabledBackgroundColor: getSurfaceColor(context),
          disabledForegroundColor: getTextPrimary(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: getBorderColor(context), width: 2),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                answer.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: getTextPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
