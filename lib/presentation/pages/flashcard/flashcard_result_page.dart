// lib/presentation/pages/vocabulary/flashcard_result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/flashcard/flashcard_action_button.dart';
import '../../widgets/flashcard/flashcard_score_progress.dart';
import '../vocabulary/vocab_by_topic_page.dart';

/// Trang hiển thị kết quả học tập flashcard
class FlashcardResultPage extends StatelessWidget {
  final int knownCount;
  final int unknownCount;
  final String topicId;
  final String topicName;

  const FlashcardResultPage({
    super.key,
    required this.knownCount,
    required this.unknownCount,
    required this.topicId,
    required this.topicName,
  });

  int get _total => knownCount + unknownCount;
  int get _percentage => _total > 0 ? (knownCount * 100 / _total).round() : 0;
  bool get _isPerfect => knownCount == _total && _total > 0;

  String get _getTitle {
    if (_isPerfect) return 'Bạn làm tốt lắm!';
    if (_percentage >= 90) return 'Tuyệt vời!';
    if (_percentage >= 70) return 'Bạn đang tiến bộ!';
    if (_percentage >= 50) return 'Khá tốt!';
    return 'Cố gắng lên!';
  }

  String get _getSubtitle {
    if (_isPerfect) return 'Bạn đã đủ kiến thúc để làm bài kiểm tra rồi đó!';
    return 'Kết quả của bạn';
  }

  @override
  Widget build(BuildContext context) {
    // Wrap với PopScope để xử lý khi user swipe back
    return PopScope(
      canPop: false, // Không cho pop mặc định
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          // Khi user swipe back hoặc nhấn nút back, luôn trả về 'go_back'
          Navigator.pop(context, 'go_back');
        }
      },
      child: Scaffold(
        backgroundColor: getBackgroundColor(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: getTextPrimary(context),
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context, 'go_back'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isPerfect)
                          // Title
                          Text(
                            _getTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: getSuccessColor(context),
                            ),
                          )
                        else
                          Text(
                            _getTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: getTextPrimary(context),
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Subtitle
                        SizedBox(
                          width: 300,
                          child: Text(
                            _getSubtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: getTextSecondary(context),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Perfect score - Trophy or Normal score - Progress
                        if (_isPerfect)
                          _buildPerfectScoreDisplay()
                        else
                          FlashcardScoreProgress(
                            knownCount: knownCount,
                            unknownCount: unknownCount,
                            percentage: _percentage,
                          ),

                        const SizedBox(height: 200),

                        // Action buttons
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ), // Close Scaffold
      ), // Close PopScope
    );
  }

  // Perfect score display with trophy
  Widget _buildPerfectScoreDisplay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy with gradient
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return kGoldCupGradient.createShader(bounds);
            },
            child: SvgPicture.asset(
              kIconTrophy,
              width: 200,
              height: 200,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (_isPerfect) {
      // Khi đã biết hết - Hiển thị nút Làm bài kiểm tra
      return Center(
        child: SizedBox(
          width: 300,
          child: FlashcardActionButton(
            icon: Icons.quiz_outlined,
            label: 'Làm bài kiểm tra',
            hasBackground: true,
            onTap: () {
              // Navigate to quiz settings
              Navigator.pushNamed(
                context,
                AppRoutes.quizSettings,
                arguments: {
                  'topicId': topicId,
                  'topicName': topicName,
                  'mode': TopicSelectionMode.flashcard,
                },
              );
            },
          ),
        ),
      );
    } else {
      // Khi chưa biết hết - Hiển thị 2 nút
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiếp tục ôn thuật ngữ - Elevated button with background
            SizedBox(
              width: 300,
              child: FlashcardActionButton(
                icon: Icons.layers,
                label: 'Tiếp tục ôn thuật ngữ',
                hasBackground: true,
                onTap: () => Navigator.pop(context, 'continue_learning'),
              ),
            ),

            const SizedBox(height: 16),

            // Đặt lại flashcard - Text button without background
            SizedBox(
              width: 300,
              child: FlashcardActionButton(
                label: 'Đặt lại Flashcard',
                hasBackground: false,
                onTap: () => Navigator.pop(context, 'study_again'),
              ),
            ),
          ],
        ),
      );
    }
  }
}
