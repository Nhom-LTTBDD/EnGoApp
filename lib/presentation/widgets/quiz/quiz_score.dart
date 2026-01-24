import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../domain/entities/quiz_result.dart';

class QuizScore extends StatelessWidget {
  final QuizResult result;
  const QuizScore({super.key, required this.result});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Score circle
        _buildScoreCircle(context),
        const SizedBox(height: spaceLg),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Correct answers badge
            _buildCountBadge(
              context,
              label: 'Đúng',
              count: result.correctAnswers,
              color: getSuccessColor(context),
              icon: Icons.check_circle,
            ),
            const SizedBox(width: spaceMd),
            // Incorrect answers badge
            _buildCountBadge(
              context,
              label: 'Sai',
              count: result.wrongAnswers,
              color: getErrorColor(context),
              icon: Icons.cancel,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final percentage = result.scorePercentage;
    final color = percentage >= 80
        ? getSuccessColor(context)
        : percentage >= 60
        ? getWarningColor(context)
        : getErrorColor(context);

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 8),
      ),
      child: Center(
        child: Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: spaceSm),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: getTextPrimary(context),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
