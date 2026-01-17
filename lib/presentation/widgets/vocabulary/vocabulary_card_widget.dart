// lib/presentation/widgets/vocabulary/vocabulary_card_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/vocabulary_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/di/injection_container.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/personal_vocabulary_provider.dart';
import 'base_card_widget.dart';

/// Widget hiển thị một vocabulary card với flip animation và bookmark.
///
/// **Features:**
/// - Flip animation khi tap vào card
/// - Bookmark button
/// - Audio playback button
/// - Optional fullscreen expand button
class VocabularyCardWidget extends StatefulWidget {
  final VocabularyCard card;
  final int index;
  final VoidCallback? onExpand;

  const VocabularyCardWidget({
    super.key,
    required this.card,
    required this.index,
    this.onExpand,
  });

  @override
  State<VocabularyCardWidget> createState() => _VocabularyCardWidgetState();
}

class _VocabularyCardWidgetState extends State<VocabularyCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  // Constants
  static const _animationDuration = Duration(milliseconds: 300);
  static const _cardHeight = 200.0;
  static const _fullscreenIconSize = 30.0;
  static const _fullscreenButtonSize = 32.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }@override
  Widget build(BuildContext context) {
    final audioService = sl<AudioService>();
    
    return Consumer2<VocabularyProvider, PersonalVocabularyProvider>(
      builder: (context, vocabProvider, personalProvider, child) {
        final isFlipped = vocabProvider.isCardFlippedAtIndex(widget.index);
        final isBookmarked = personalProvider.isBookmarked(widget.card.id);

        // Sync animation với trạng thái flip
        if (isFlipped && !_animationController.isCompleted) {
          _animationController.forward();
        } else if (!isFlipped && !_animationController.isDismissed) {
          _animationController.reverse();
        }

        return GestureDetector(
          onTap: () {
            vocabProvider.flipCardAtIndex(widget.index);
          },          child: BaseCardWidget(
            card: widget.card,
            flipAnimation: _flipAnimation,
            isFlipped: isFlipped,
            style: CardStyle.simple,
            height: _cardHeight,
            isBookmarked: isBookmarked,
            onBookmarkPressed: () async {
              await personalProvider.toggleBookmark(widget.card.id);
            },
            onSoundPressed: () async {
              await audioService.playAudio(widget.card.audioUrl);
            },
            extraWidget: widget.onExpand != null
                ? Positioned(
                    bottom: 4,
                    right: 0,
                    child: TextButton(
                      onPressed: widget.onExpand,
                      child: SizedBox(
                        width: _fullscreenButtonSize,
                        height: _fullscreenButtonSize,
                        child: Icon(
                          Icons.fullscreen,
                          size: _fullscreenIconSize,
                          color: kFullscreenButtonColor,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
