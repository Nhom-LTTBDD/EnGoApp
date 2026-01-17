// lib/presentation/widgets/vocabulary/flashcard_score_display.dart
import 'package:flutter/material.dart';

/// Widget hiển thị điểm số đúng/sai
class FlashcardScoreDisplay extends StatelessWidget {
  final int correctCount;
  final int wrongCount;

  const FlashcardScoreDisplay({
    super.key,
    required this.correctCount,
    required this.wrongCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Điểm sai (màu đỏ) - bên trái
        _buildScoreContainer(count: wrongCount, color: Colors.red),

        // Điểm đúng (màu xanh) - bên phải
        _buildScoreContainer(count: correctCount, color: Colors.green),
      ],
    );
  }

  Widget _buildScoreContainer({
    required int count,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade300),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color.shade700,
        ),
      ),
    );
  }
}
