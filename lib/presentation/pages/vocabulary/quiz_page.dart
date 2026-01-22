// lib/presentation/pages/vocabulary/quiz_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
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
  List<QuestionResult> _questionResults = []; // Remove final
  String? _selectedAnswerId; // Add this
  bool _hasAnswered = false;
  bool _questionsGenerated =
      false; // Flag to track if questions have been generated

  @override
  void initState() {
    super.initState();
    // Reset state for new quiz
    _questionsGenerated = false;
    _questions = [];
    _questionResults = [];
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _selectedAnswerId = null;
    _hasAnswered = false;

    // Debug log
    debugPrint('QuizPage initState - Config: ${widget.config}');
    _loadQuizData();
  }

  void _loadQuizData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Debug log
      debugPrint('Loading quiz data for topic: ${widget.config.topicId}');
      // Clear old cards first to force reload
      final provider = context.read<VocabularyProvider>();
      provider.clearCards(); // Clear old data

      // Wait for vocabulary cards to load completely
      await provider.loadVocabularyCards(widget.config.topicId);

      // After cards loaded, generate questions if not already generated
      if (mounted &&
          !_questionsGenerated &&
          provider.vocabularyCards.isNotEmpty) {
        debugPrint('Cards loaded, now generating questions...');
        _generateQuestions(provider.vocabularyCards);
      }
    });
  }

  /// Generate quiz questions from vocabulary cards
  void _generateQuestions(List<VocabularyCard> cards) {
    if (cards.length < 4) {
      debugPrint('Not enough cards to generate quiz (minimum 4 required)');
      return;
    }

    final random = Random();
    final shuffledCards = List<VocabularyCard>.from(cards)..shuffle(random);
    final questionCount = min(
      widget.config.questionCount,
      shuffledCards.length,
    );

    final List<QuizQuestion> questions =
        []; // Use local variable instead of setState

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

    debugPrint('Generated ${questions.length} questions');

    // Update state immediately since we're called from async function
    if (mounted && !_questionsGenerated) {
      setState(() {
        _questions = questions;
        _questionsGenerated = true;
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

    debugPrint('Quiz completed: $result');

    // Navigate to result page
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
      child: Consumer<VocabularyProvider>(
        builder: (context, vocabProvider, child) {
          // Loading state (both provider loading OR questions not generated yet)
          if (vocabProvider.isLoading || _questions.isEmpty) {
            return _buildLoadingState();
          }

          // Error state
          if (vocabProvider.error != null) {
            return _buildErrorState(vocabProvider);
          }

          final currentQuestion = _questions[_currentQuestionIndex];

          return Container(
            decoration: BoxDecoration(color: getBackgroundColor(context)),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(spaceMd),
                child: Column(
                  children: [
                    // Progress indicator
                    _buildProgressIndicator(_questions.length),

                    const SizedBox(height: spaceLg),

                    // // Score display
                    const SizedBox(height: spaceLg),

                    // Question card
                    Expanded(child: _buildQuestionCard(currentQuestion)),

                    const SizedBox(height: spaceLg),

                    // Answer options
                    _buildAnswerOptions(currentQuestion),
                    const SizedBox(height: spaceMd),
                  ],
                ),
              ),
            ),
          );
        },
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

  Widget _buildErrorState(VocabularyProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: spaceMd),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: spaceSm),
          Text(
            provider.error!,
            style: TextStyle(color: getTextSecondary(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spaceMd),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: getTextThird(context)),
          const SizedBox(height: spaceMd),
          Text(
            'Không có câu hỏi nào',
            style: TextStyle(fontSize: 18, color: getTextSecondary(context)),
          ),
          const SizedBox(height: spaceMd),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
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
