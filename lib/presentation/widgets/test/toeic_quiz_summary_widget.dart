import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_helper.dart';
import '../../providers/toeic_test_provider.dart';

/// ToeicQuizSummaryWidget - Lưới câu hỏi (9 cột)
///
/// Hiển thị tất cả câu hỏi dạng grid 9 cột cho phép user:
/// - Xem tất cả câu hỏi cùng lúc
/// - Nhảy tới câu cụ thể bằng tap
/// - Biết trạng thái: đang làm (xanh), đã trả lời (xám), chưa trả lời (trắng)
///
/// Color system:
/// - Primary (xanh) = câu hiện tại
/// - Disabled (xám) = đã trả lời
/// - Surface (trắng) = chưa trả lời
class ToeicQuizSummaryWidget extends StatelessWidget {
  const ToeicQuizSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ToeicTestProvider>(
      builder: (context, provider, _) {
        return _buildQuestionGrid(context, provider);
      },
    );
  }

  /// Build grid layout: 9 columns × N rows
  /// - Each cell = 1 question number
  /// - Tap cell → goToQuestion(index) in provider
  /// - Colors indicate: current (primary), answered (disabled), unanswered (surface)
  Widget _buildQuestionGrid(BuildContext context, ToeicTestProvider provider) {
    const itemsPerRow = 9;
    final questions = provider.questions;
    if (questions.isEmpty) return Container();

    final questionNumbers = questions.map((q) => q.questionNumber).toList()
      ..sort();
    final totalQuestions = questions.length;
    final rows = (totalQuestions / itemsPerRow).ceil();

    return Container(
      child: Column(
        children: List.generate(rows, (rowIndex) {
          final startIndex = rowIndex * itemsPerRow;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(itemsPerRow, (colIndex) {
                final questionIndex = startIndex + colIndex;
                if (questionIndex >= totalQuestions) {
                  return Expanded(child: Container());
                }

                final actualQuestionNumber = questionNumbers[questionIndex];
                final isAnswered =
                    provider.getAnswer(actualQuestionNumber) != null;
                final isCurrent = questionIndex == provider.currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.goToQuestion(questionIndex),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context).primaryColor
                            : isAnswered
                            ? getDisabledColor(context)
                            : getSurfaceColor(context),
                        border: Border.all(
                          color: getBorderColor(context),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: getTextPrimary(context).withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          actualQuestionNumber.toString(),
                          style: TextStyle(
                            color: isCurrent
                                ? getSurfaceColor(context)
                                : getTextPrimary(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
