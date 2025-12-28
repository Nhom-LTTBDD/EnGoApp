// lib/presentation/widgets/vocabulary/flashcard_widget.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/vocabulary_card.dart';
import 'base_card_widget.dart';

class FlashcardWidget extends StatelessWidget {
  final VocabularyCard card;
  final Animation<double> flipAnimation;
  final bool isFlipped;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.flipAnimation,
    required this.isFlipped,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCardWidget(
      card: card,
      flipAnimation: flipAnimation,
      isFlipped: isFlipped,
      style: CardStyle.flashcard,
      onSoundPressed: () {
        print('Play sound for: ${card.english}');
      },
    );
  }
}
