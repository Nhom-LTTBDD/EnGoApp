import 'package:flutter/material.dart';
import 'flashcard_compact_score.dart';

/// Widget hiển thị circular progress và số từ đã biết/chưa biết
class FlashcardScoreProgress extends StatelessWidget {
  final int knownCount;
  final int unknownCount;
  final int percentage;

  const FlashcardScoreProgress({
    super.key,
    required this.knownCount,
    required this.unknownCount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left - Circular progress
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: percentage / 100),
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

        // Right side - Known/Unknown counts
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlashcardCompactScore(
              knownCount: knownCount,
              unknownCount: unknownCount,
            ),
          ],
        ),
      ],
    );
  }

  Color _getPercentageColor() {
    if (percentage >= 90) return Colors.green.shade600;
    if (percentage >= 70) return Colors.lightGreen.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}
