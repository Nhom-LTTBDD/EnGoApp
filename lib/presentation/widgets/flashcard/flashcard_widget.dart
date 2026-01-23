// lib/presentation/widgets/vocabulary/flashcard_widget.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/vocabulary_card.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/di/injection_container.dart';
import '../vocabulary/base_card_widget.dart';

class FlashcardWidget extends StatelessWidget {
  final VocabularyCard card;
  final Animation<double> flipAnimation;
  final bool isFlipped;
  final bool isBookmarked;
  final VoidCallback? onBookmarkPressed;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.flipAnimation,
    required this.isFlipped,
    this.isBookmarked = false,
    this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    final audioService = sl<AudioService>();

    return BaseCardWidget(
      card: card,
      flipAnimation: flipAnimation,
      isFlipped: isFlipped,
      style: CardStyle.flashcard,
      isBookmarked: isBookmarked,
      onBookmarkPressed: onBookmarkPressed,
      onSoundPressed: () async {
        // Phát audio từ card.audioUrl
        await audioService.playAudio(card.audioUrl);
      },
    );
  }
}
