import 'package:flutter/material.dart';

class FlashcardCompactScore extends StatelessWidget {
  final int knownCount;
  final int unknownCount;

  const FlashcardCompactScore({
    super.key,
    required this.knownCount,
    required this.unknownCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactScoreCard(
          count: knownCount,
          label: 'Biết',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildCompactScoreCard(
          count: unknownCount,
          label: 'Đang học',
          color: Colors.red,
        ),
      ],
    );
  }
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
