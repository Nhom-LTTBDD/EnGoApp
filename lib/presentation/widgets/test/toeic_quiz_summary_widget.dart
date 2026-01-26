// lib/presentation/widgets/test/toeic_quiz_summary_widget.dart
// Widget để hiển thị bảng tóm tắt tất cả câu hỏi trong TOEIC test
// Cho phép người dùng xem tổng quan và nhảy đến câu hỏi cụ thể

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_helper.dart';
import '../../providers/toeic_test_provider.dart';

/// Widget hiển thị bảng grid tóm tắt tất cả câu hỏi
/// - Hiển thị số thứ tự câu hỏi trong lưới 9 cột
/// - Màu sắc thể hiện trạng thái: đang chọn (xanh), đã trả lời (xám), chưa trả lời (trắng)
/// - Cho phép tap để nhảy đến câu hỏi đó
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

  /// Build UI cho question grid - bảng hiển thị tất cả câu hỏi
  /// Hiển thị 9 câu hỏi trên mỗi hàng, mỗi ô có thể tap để chuyển đến câu hỏi đó
  Widget _buildQuestionGrid(BuildContext context, ToeicTestProvider provider) {
    const itemsPerRow = 9; // Số câu hỏi trên mỗi hàng - cố định 9 cột
    final questions =
        provider.questions; // Lấy danh sách tất cả câu hỏi từ provider
    if (questions.isEmpty)
      return Container(); // Trả về container rỗng nếu không có câu hỏi

    // Lấy danh sách số thứ tự câu hỏi thực tế từ các câu hỏi đã load
    final questionNumbers = questions.map((q) => q.questionNumber).toList()
      ..sort(); // Sắp xếp theo thứ tự tăng dần
    final totalQuestions = questions.length; // Tổng số câu hỏi

    final rows = (totalQuestions / itemsPerRow)
        .ceil(); // Tính số hàng cần thiết (làm tròn lên)

    return Container(
      child: Column(
        children: List.generate(rows, (rowIndex) {
          // Tạo từng hàng
          final startIndex =
              rowIndex * itemsPerRow; // Index bắt đầu của hàng này

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 6,
            ), // Khoảng cách 6px giữa các hàng
            child: Row(
              children: List.generate(itemsPerRow, (colIndex) {
                // Tạo 9 cột cho mỗi hàng
                final questionIndex =
                    startIndex + colIndex; // Index câu hỏi hiện tại
                if (questionIndex >= totalQuestions) {
                  return Expanded(
                    child: Container(),
                  ); // Container rỗng nếu vượt quá số câu hỏi
                }

                // Sử dụng số thứ tự câu hỏi thực tế từ danh sách đã load
                final actualQuestionNumber = questionNumbers[questionIndex];
                final isAnswered =
                    provider.getAnswer(actualQuestionNumber) !=
                    null; // Kiểm tra đã trả lời chưa
                final isCurrent =
                    questionIndex ==
                    provider.currentIndex; // Kiểm tra có phải câu hiện tại

                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.goToQuestion(
                      questionIndex,
                    ), // Chuyển đến câu hỏi khi tap
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ), // Margin ngang 2px mỗi bên
                      height: 36, // Chiều cao cố định 36px cho mỗi ô
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context)
                                  .primaryColor // Màu xanh dương cho câu hiện tại
                            : isAnswered
                            ? getDisabledColor(
                                context,
                              ) // Màu xám cho câu đã trả lời
                            : getSurfaceColor(
                                context,
                              ), // Màu trắng cho câu chưa trả lời
                        border: Border.all(
                          color: getBorderColor(context),
                          width: 1,
                        ), // Viền xám nhạt dày 1px
                        borderRadius: BorderRadius.circular(6), // Bo góc 6px
                        boxShadow: [
                          BoxShadow(
                            color: getTextPrimary(
                              context,
                            ).withOpacity(0.1), // Màu bóng đen trong suốt 10%
                            offset: const Offset(
                              0,
                              2,
                            ), // Độ lệch bóng: 0px ngang, 2px dọc
                            blurRadius: 2, // Độ mờ của bóng 2px
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          actualQuestionNumber
                              .toString(), // Hiển thị số thứ tự câu hỏi thực tế
                          style: TextStyle(
                            color: isCurrent
                                ? getSurfaceColor(context)
                                : getTextPrimary(
                                    context,
                                  ), // Màu chữ: trắng nếu đang chọn, đen nếu không
                            fontWeight:
                                FontWeight.w600, // Độ đậm font: semibold
                            fontSize: 14, // Cỡ chữ 14px
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
