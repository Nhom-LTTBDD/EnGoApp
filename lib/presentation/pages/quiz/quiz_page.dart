// lib/presentation/pages/vocabulary/quiz_page.dart
import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../core/utils/isolate_helpers.dart';
import '../../../domain/entities/quiz_config.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../../domain/entities/quiz_answer.dart';
import '../../../domain/entities/quiz_result.dart';
import '../../../domain/entities/quiz_language_mode.dart';
import '../../../domain/entities/vocabulary_card.dart';
import '../../../domain/entities/question_type.dart';
import '../../../data/repositories/vocabulary_repository_impl.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/quiz/quiz_widget.dart';
import '../vocabulary/vocab_by_topic_page.dart';

/// Page làm quiz theo topic
class QuizPage extends StatefulWidget {
  final QuizConfig config;
  final TopicSelectionMode mode;

  const QuizPage({super.key, required this.config, required this.mode});

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
          await _generateQuestionsInIsolate(cards);
        } else {
          debugPrint('[QUIZ] Cannot generate - cards empty or unmounted');
        }
      } catch (e) {
        debugPrint('[QUIZ] Error: $e');
      }
    });
  }

  /// Generate quiz questions using isolate (compute) để tránh skip frame
  Future<void> _generateQuestionsInIsolate(List<VocabularyCard> cards) async {
    if (cards.length < widget.config.questionType.answerCount) {
      debugPrint(
        '[QUIZ] Not enough cards (need ${widget.config.questionType.answerCount}, got ${cards.length})',
      );
      return;
    }

    debugPrint('[QUIZ] Starting isolate computation...');
    final startTime = DateTime.now();

    // Chạy trong isolate bằng compute
    final simpleQuestions = await generateQuizQuestions(
      cards: cards,
      questionCount: widget.config.questionCount,
      answerCount: widget.config.questionType.answerCount,
      languageMode: widget.config.answerLanguage,
    );

    final duration = DateTime.now().difference(startTime);
    debugPrint('[QUIZ] Isolate completed in ${duration.inMilliseconds}ms');

    // Convert SimpleQuizQuestion to QuizQuestion with correct card reference
    final questions = simpleQuestions.map((sq) {
      final correctCard = cards.firstWhere((c) => c.id == sq.correctCardId);
      return QuizQuestion(
        questionText: sq.questionText,
        correctCard: correctCard,
        answers: sq.answers,
        questionNumber: sq.questionNumber,
      );
    }).toList();

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
      arguments: {'result': result, 'mode': widget.mode},
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
                  child: QuizWidget(
                    questions: _questions,
                    config: widget.config,
                    currentQuestionIndex: _currentQuestionIndex,
                    hasAnswered: _hasAnswered,
                    onAnswerTap: _handleAnswerTap,
                    onClose: () => Navigator.pop(context),
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
}
