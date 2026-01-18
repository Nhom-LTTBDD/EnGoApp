// lib/presentation/widgets/vocabulary/flashcard_controls.dart
import 'package:flutter/material.dart';

/// Widget chứa các nút điều khiển flashcard
/// Bao gồm: Nút undo (quay lại thẻ trước)
class FlashcardControls extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback? onPlayPause;
  final bool canUndo;

  const FlashcardControls({
    super.key,
    required this.onUndo,
    this.onPlayPause,
    this.canUndo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút undo (quay lại thẻ trước)
        IconButton(
          onPressed: canUndo ? onUndo : null,
          icon: Icon(
            Icons.replay,
            size: 32,
            color: canUndo ? Colors.orange : Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
