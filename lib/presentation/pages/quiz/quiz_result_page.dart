// lib/presentation/pages/vocabulary/quiz_result_page.dart
import 'package:en_go_app/presentation/pages/vocabulary/vocab_by_topic_page.dart';
import 'package:en_go_app/presentation/widgets/quiz/quiz_action_button.dart';
import 'package:en_go_app/presentation/widgets/quiz/quiz_result_of_answer.dart';
import 'package:en_go_app/presentation/widgets/quiz/quiz_score.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../domain/entities/quiz_result.dart';
import '../../layout/main_layout.dart';

/// Page hiển thị kết quả quiz
class QuizResultPage extends StatelessWidget {
  final QuizResult result;
  final TopicSelectionMode mode;

  const QuizResultPage({super.key, required this.result, required this.mode});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable back navigation - use action buttons instead
      child: MainLayout(
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
                            'Bạn đang tiến bộ!',
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

                          // Score
                          QuizScore(result: result),

                          const SizedBox(height: spaceLg),

                          // Answer details
                          QuizResultOfAnswer(result: result),

                          const SizedBox(height: spaceLg),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  QuizActionButtons(
                    result: result,
                    mode: mode, // ← Pass mode to action buttons
                  ),
                ],
              ),
            ),
          ),
        ), // Close MainLayout child (Container)
      ),
    ); // Close PopScope
  }
}
