// lib/presentation/widgets/vocabulary/flashcard_score_display.dart
import 'package:flutter/material.dart';

/// Widget hiển thị điểm số đúng/sai
class FlashcardScoreDisplay extends StatelessWidget {
  final int knownCount;
  final int unknownCount;

  const FlashcardScoreDisplay({
    super.key,
    required this.knownCount,
    required this.unknownCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Điểm sai (màu đỏ) - bên trái
        _buildScoreContainer(count: unknownCount, color: Colors.red),

        // Điểm đúng (màu xanh) - bên phải
        _buildScoreContainer(count: knownCount, color: Colors.green),
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
