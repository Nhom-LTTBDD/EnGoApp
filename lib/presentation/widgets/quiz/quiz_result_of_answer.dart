import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../domain/entities/quiz_result.dart';

class QuizResultOfAnswer extends StatelessWidget {
  final QuizResult result;

  const QuizResultOfAnswer({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đáp án của bạn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: getTextPrimary(context),
            ),
          ),
          const SizedBox(height: spaceMd),
          ...result.questionResults.asMap().entries.map((entry) {
            final index = entry.key;
            final questionResult = entry.value;
            return _buildAnswerRow(context, index + 1, questionResult);
          }),
        ],
      ),
    );
  }
}

Widget _buildAnswerRow(
  BuildContext context,
  int questionNumber,
  QuestionResult questionResult,
) {
  final color = questionResult.isCorrect
      ? getSuccessColor(context)
      : getErrorColor(context);

  return Padding(
    padding: const EdgeInsets.only(bottom: spaceSm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(
              '$questionNumber',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: getTextPrimary(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: spaceSm),
        // Answer details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questionResult.questionText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: getTextPrimary(context),
                ),
              ),
              if (!questionResult.isCorrect) ...[
                const SizedBox(height: 4),
                Text(
                  'Nghĩa sai: ${questionResult.userAnswer}',
                  style: TextStyle(fontSize: 12, color: getErrorColor(context)),
                ),
                Text(
                  'Nghĩa đúng: ${questionResult.correctAnswer}',
                  style: TextStyle(
                    fontSize: 12,
                    color: getSuccessColor(context),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  'Đúng',
                  style: TextStyle(
                    fontSize: 12,
                    color: getSuccessColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Status icon
        Icon(
          questionResult.isCorrect ? Icons.check_circle : Icons.cancel,
          color: color,
          size: 24,
        ),
      ],
    ),
  );
}
