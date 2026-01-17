// lib/presentation/pages/vocabulary/flashcard_result_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
    if (_isPerfect) return 'Bạn đã biết hết tất cả các từ!';
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
                        // Title
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
                        Text(
                          _getSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: getTextSecondary(context),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Circular progress with score cards
                        _buildCircularProgressWithScores(),

                        const SizedBox(height: 40),

                        // Action buttons - only show if not perfect
                        if (!_isPerfect) _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bottom button - Continue or back
                _buildBottomButton(context),
              ],
            ),
          ),
        ), // Close Scaffold
      ), // Close PopScope
    );
  }

  // Circular progress with score cards beside
  Widget _buildCircularProgressWithScores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Center - Circular progress
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: _percentage / 100),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade300,
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPercentageColor(),
                      ),
                    ),
                  ),
                  // Percentage text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(value * 100).round()}%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getPercentageColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(width: 16),

        // right side - Score cards in column
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.shade200, width: 2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 32,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Tiếp tục ôn thuật ngữ
          _buildActionButton(
            context: context,
            icon: Icons.layers,
            label: 'Tiếp tục ôn\nthuật ngữ',
            color: kPrimaryColor,
            onTap: () => Navigator.pop(context, 'go_back'),
          ),

          Container(width: 1, height: 60, color: getBorderColor(context)),

          // Đặt lại flashcard
          _buildActionButton(
            context: context,
            icon: Icons.replay,
            label: 'Đặt lại\nFlashcard',
            color: Colors.orange.shade600,
            onTap: () => Navigator.pop(context, 'study_again'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: getTextPrimary(context),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    if (_isPerfect) {
      // Nếu perfect, chỉ hiển thị nút Quay lại
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, 'go_back'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_back, size: 24),
              SizedBox(width: 8),
              Text(
                'Quay lại',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    } else {
      // Nếu chưa perfect, hiển thị nút Đặt lại Flashcard
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, 'study_again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.replay, size: 24),
              SizedBox(width: 8),
              Text(
                'Đặt lại Flashcard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
