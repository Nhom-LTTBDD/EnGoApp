// lib/presentation/pages/vocabulary/flashcard_result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/theme_helper.dart';

/// Trang hiển thị kết quả học tập flashcard
class FlashcardResultPage extends StatelessWidget {
  final int correctCount;
  final int wrongCount;

  const FlashcardResultPage({
    super.key,
    required this.correctCount,
    required this.wrongCount,
  });

  int get _total => correctCount + wrongCount;
  int get _percentage => _total > 0 ? (correctCount * 100 / _total).round() : 0;
  bool get _isPerfect => correctCount == _total && _total > 0;

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
                              color: Colors.green,
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
                          _buildCircularProgressWithScores(),

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

  // Circular progress with score cards beside
  Widget _buildCircularProgressWithScores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left - Circular progress
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: _percentage / 100),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade300,
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPercentageColor(),
                      ),
                    ),
                  ),
                  // Percentage text
                  Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getPercentageColor(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(width: 24),

        // Right side - Score cards in column
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactScoreCard(
              count: correctCount,
              label: 'Biết',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildCompactScoreCard(
              count: wrongCount,
              label: 'Đang học',
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactScoreCard({
    required int count,
    required String label,
    required MaterialColor color,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.shade200, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: color.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (_isPerfect) {
      // Khi đã biết hết - Hiển thị nút Làm bài kiểm tra
      return Center(
        child: SizedBox(
          width: 300,
          child: _buildActionButton(
            context: context,
            icon: Icons.quiz_outlined,
            label: 'Làm bài kiểm tra',
            hasBackground: true,
            onTap: () => Navigator.pop(context, 'go_back'),
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
              child: _buildActionButton(
                context: context,
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
              child: _buildActionButton(
                context: context,
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

  Widget _buildActionButton({
    required BuildContext context,
    IconData? icon,
    required String label,
    required bool hasBackground,
    required VoidCallback onTap,
  }) {
    if (hasBackground) {
      // Elevated button with background and shadow
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 20),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    } else {
      // Text button without background
      return TextButton(
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: getTextPrimary(context),
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    }
  }

  Color _getPercentageColor() {
    if (_percentage >= 90) return Colors.green.shade600;
    if (_percentage >= 70) return Colors.lightGreen.shade600;
    if (_percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}

// Remove old unused methods below
