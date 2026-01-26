import 'package:flutter/material.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../../domain/entities/quiz_answer.dart';
import '../../../domain/entities/quiz_config.dart';
import '../../../domain/entities/quiz_language_mode.dart';

class QuizWidget extends StatefulWidget {
  final List<QuizQuestion> questions;
  final QuizConfig config;
  final int currentQuestionIndex;
  final bool hasAnswered;
  final Function(QuizAnswer) onAnswerTap;
  final VoidCallback onClose;

  const QuizWidget({
    super.key,
    required this.questions,
    required this.config,
    required this.currentQuestionIndex,
    required this.hasAnswered,
    required this.onAnswerTap,
    required this.onClose,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[widget.currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProgressIndicator(widget.questions.length),
        const SizedBox(height: spaceLg),
        Expanded(child: _buildQuestionCard(currentQuestion)),
        const SizedBox(height: spaceLg),
        _buildAnswerOptions(currentQuestion),
        const SizedBox(height: spaceMd),
      ],
    );
  }

  Widget _buildProgressIndicator(int totalQuestions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: widget.onClose,
          icon: Icon(Icons.close, color: getTextPrimary(context)),
        ),
        Text(
          'Câu ${widget.currentQuestionIndex + 1} / $totalQuestions',
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
    final showResult = widget.hasAnswered;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: showResult ? null : () => widget.onAnswerTap(answer),
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
