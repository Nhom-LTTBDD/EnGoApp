// lib/presentation/widgets/vocabulary/flashcard_header.dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme_helper.dart';

/// Widget hiển thị header của flashcard page
/// Bao gồm: Nút đóng, progress counter
class FlashcardHeader extends StatelessWidget {
  final VoidCallback onClose;
  final int currentIndex;
  final int totalCards;

  const FlashcardHeader({
    super.key,
    required this.onClose,
    required this.currentIndex,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    // Đảm bảo displayIndex không vượt quá totalCards
    final displayIndex = (currentIndex + 1) > totalCards
        ? totalCards
        : (currentIndex + 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút X để đóng
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, color: getTextPrimary(context), size: 28),
        ),

        // Progress hiển thị ở giữa
        Text(
          '$displayIndex / $totalCards',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: getTextPrimary(context),
          ),
        ),

        // Placeholder để cân bằng layout
        const SizedBox(width: 48),
      ],
    );
  }
}
