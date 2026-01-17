// lib/presentation/widgets/vocabulary/flashcard_result_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_helper.dart';

/// Dialog hiển thị kết quả học tập
class FlashcardResultDialog extends StatelessWidget {
  final int correctCount;
  final int wrongCount;
  final VoidCallback onGoBack;
  final VoidCallback onStudyAgain;

  const FlashcardResultDialog({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.onGoBack,
    required this.onStudyAgain,
  });

  int get _total => correctCount + wrongCount;
  int get _percentage => _total > 0 ? (correctCount * 100 / _total).round() : 0;
  bool get _isPerfect => correctCount == _total && _total > 0;
  bool get _isGoodProgress => _percentage >= 70;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: getSurfaceColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon và animation khác nhau dựa trên kết quả
          if (_isPerfect) _buildPerfectResult() else _buildProgressResult(),

          const SizedBox(height: 24),

          // Điểm số
          _buildScoreDisplay(),

          const SizedBox(height: 16),

          // Tỷ lệ đúng với progress bar
          _buildPercentageDisplay(),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onGoBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: getBorderColor(context)),
                ),
                child: Text(
                  'Quay lại',
                  style: TextStyle(
                    fontSize: 16,
                    color: getTextPrimary(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onStudyAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Học lại',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget cho kết quả hoàn hảo
  Widget _buildPerfectResult() {
    return Column(
      children: [
        // Trophy animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Transform.rotate(angle: (1 - value) * 0.5, child: child),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: 80,
              color: Colors.amber.shade600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bạn làm tốt lắm!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bạn đã biết hết tất cả các từ!',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget cho kết quả đang tiến bộ
  Widget _buildProgressResult() {
    return Column(
      children: [
        // Progress animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isGoodProgress
                  ? Colors.green.shade50
                  : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isGoodProgress ? Icons.trending_up : Icons.lightbulb_outline,
              size: 80,
              color: _isGoodProgress
                  ? Colors.green.shade600
                  : Colors.blue.shade600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isGoodProgress ? 'Bạn đang tiến bộ!' : 'Cố gắng lên!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isGoodProgress
                ? Colors.green.shade700
                : Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getMessage(),
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getMessage() {
    if (_percentage >= 90) return 'Tuyệt vời! Bạn sắp thuộc hết rồi!';
    if (_percentage >= 70) return 'Tốt lắm! Hãy tiếp tục phát huy!';
    if (_percentage >= 50) return 'Khá tốt! Hãy cố gắng thêm nhé!';
    return 'Đừng lo! Luyện tập nhiều hơn sẽ tốt hơn!';
  }

  Widget _buildScoreDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreCard(
          count: correctCount,
          label: 'Biết',
          color: Colors.green,
          icon: Icons.check_circle,
        ),
        const SizedBox(width: 24),
        _buildScoreCard(
          count: wrongCount,
          label: 'Đang học',
          color: Colors.red,
          icon: Icons.refresh,
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required int count,
    required String label,
    required MaterialColor color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade200, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade600, size: 28),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageDisplay() {
    return Column(
      children: [
        // Progress bar
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: _percentage / 100),
          builder: (context, value, child) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kết quả của bạn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${(value * 100).round()}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getPercentageColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getPercentageColor(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _getPercentageColor() {
    if (_percentage >= 90) return Colors.green.shade600;
    if (_percentage >= 70) return Colors.lightGreen.shade600;
    if (_percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}
