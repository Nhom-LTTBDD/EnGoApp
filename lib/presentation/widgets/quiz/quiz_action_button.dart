import 'package:en_go_app/domain/entities/quiz_result.dart';
import 'package:en_go_app/presentation/pages/vocabulary/vocab_by_topic_page.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/theme_helper.dart';

class QuizActionButtons extends StatelessWidget {
  final QuizResult result;
  final TopicSelectionMode mode;

  const QuizActionButtons({
    super.key,
    required this.result,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Retry button - Go back to quiz settings
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Simply pop back to quiz settings and push it again
              // This works because Result page replaced Quiz page
              // Stack: [...previous pages] → Settings → [Result (replaced Quiz)]
              // After pop: [...previous pages] → Settings
              // After push: [...previous pages] → Settings → New Settings

              Navigator.pop(context); // Pop Result page

              // Then push settings again for retry
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.quizSettings,
                arguments: {
                  'topicId': result.topicId,
                  'topicName': result.topicName,
                  'mode': mode,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Làm bài kiểm tra mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: spaceSm),
        // Back to home
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.vocab,
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: getBorderColor(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Về trang chủ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: getTextPrimary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
