// lib/presentation/widgets/vocabulary/flashcard_controls.dart
import 'package:flutter/material.dart';

/// Widget chứa các nút điều khiển flashcard
/// Bao gồm: Nút reset, nút play/pause
class FlashcardControls extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback? onPlayPause;

  const FlashcardControls({super.key, required this.onReset, this.onPlayPause});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút reset (quay lại)
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.replay, size: 32, color: Colors.grey),
        ),

        // Nút play/pause
        IconButton(
          onPressed:
              onPlayPause ??
              () {
                // TODO: Auto play cards
                print('Auto play flashcards');
              },
          icon: const Icon(Icons.play_arrow, size: 32, color: Colors.grey),
        ),
      ],
    );
  }
}
