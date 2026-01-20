// lib/presentation/pages/vocabulary/quiz_result_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../domain/entities/quiz_result.dart';
import '../../../routes/app_routes.dart';
import '../../layout/main_layout.dart';

/// Page hiển thị kết quả quiz
class QuizResultPage extends StatelessWidget {
  final QuizResult result;

  const QuizResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'VOCABULARY',
      currentIndex: -1,
      showBottomNav: false,
      child: Container(
        decoration: BoxDecoration(color: getBackgroundColor(context)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(spaceMd),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: spaceLg),

                        // Success message
                        Text(
                          'Bạn đồng tiến bộ!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: getTextPrimary(context),
                          ),
                        ),

                        const SizedBox(height: spaceMd),

                        // Result message
                        Text(
                          'Kết quả của bạn',
                          style: TextStyle(
                            fontSize: 16,
                            color: getTextSecondary(context),
                          ),
                        ),

                        const SizedBox(height: spaceLg),

                        // Score circle
                        _buildScoreCircle(context),

                        const SizedBox(height: spaceLg),

                        // Correct/Wrong count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCountBadge(
                              context,
                              label: 'Đúng',
                              count: result.correctAnswers,
                              color: Colors.green,
                              icon: Icons.check_circle,
                            ),
                            const SizedBox(width: spaceMd),
                            _buildCountBadge(
                              context,
                              label: 'Sai',
                              count: result.wrongAnswers,
                              color: Colors.red,
                              icon: Icons.cancel,
                            ),
                          ],
                        ),

                        const SizedBox(height: spaceLg),

                        // Answer details
                        _buildAnswerDetails(context),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final percentage = result.scorePercentage;
    final color = percentage >= 80
        ? Colors.green
        : percentage >= 60
        ? Colors.orange
        : Colors.red;

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
    required MaterialColor color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade700, size: 32),
          const SizedBox(height: spaceSm),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color.shade900,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 14, color: color.shade700)),
        ],
      ),
    );
  }

  Widget _buildAnswerDetails(BuildContext context) {
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

  Widget _buildAnswerRow(
    BuildContext context,
    int questionNumber,
    QuestionResult questionResult,
  ) {
    final color = questionResult.isCorrect ? Colors.green : Colors.red;

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
              color: color.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: color.shade300),
            ),
            child: Center(
              child: Text(
                '$questionNumber',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.shade900,
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
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                  Text(
                    'Nghĩa đúng: ${questionResult.correctAnswer}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    'Đúng',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
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
            color: color.shade700,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Retry button - Go back to quiz settings
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to quiz settings to allow user to configure again
              // First, remove all routes
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Then push quiz settings with arguments
              Navigator.pushNamed(
                context,
                AppRoutes.quizSettings,
                arguments: {
                  'topicId': result.topicId,
                  'topicName': result.topicName,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
