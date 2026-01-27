// lib/presentation/widgets/vocabulary/flashcard_swipe_card.dart
import 'package:en_go_app/core/constants/flashcard_constants.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/vocabulary_card.dart';
import '../../../core/theme/theme_helper.dart';
import 'flashcard_widget.dart';

/// Widget card có thể swipe với gesture
class FlashcardSwipeCard extends StatelessWidget {
  final VocabularyCard card;
  final Animation<double> flipAnimation;
  final bool isFlipped;
  final bool isCurrentCard;
  final bool isDragging;
  final bool isCommittedToSwipe;
  final double dragOffset;
  final double dragOffsetY;
  final VoidCallback onTap;
  final Function(DragStartDetails) onPanStart;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;
  final bool isBookmarked;
  final VoidCallback? onBookmarkPressed;

  const FlashcardSwipeCard({
    super.key,
    required this.card,
    required this.flipAnimation,
    required this.isFlipped,
    required this.isCurrentCard,
    required this.isDragging,
    required this.isCommittedToSwipe,
    required this.dragOffset,
    required this.dragOffsetY,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.isBookmarked = false,
    this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Chỉ thẻ hiện tại mới nhận touch events
      ignoring: !isCurrentCard,
      child: Opacity(
        opacity: isCurrentCard ? 1.0 : 0.0,
        child: AnimatedContainer(
          duration: isCurrentCard && isDragging
              ? Duration.zero
              : const Duration(
                  milliseconds: FlashcardConstants.swipeAnimationDuration,
                ),
          curve: Curves.easeOut,
          transform: isCurrentCard
              ? (Matrix4.identity()
                  ..translate(dragOffset, dragOffsetY)
                  ..rotateZ(dragOffset * FlashcardConstants.rotationFactor))
              : Matrix4.identity(),
          child: Container(
            width: double.infinity,
            height: FlashcardConstants.cardHeight,
            decoration: BoxDecoration(
              color: getSurfaceColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: getBorderColor(context)),
              boxShadow: [
                BoxShadow(
                  color: getTextPrimary(context).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Nội dung thẻ
                if (isCurrentCard)
                  Opacity(
                    opacity: _calculateOpacity(),
                    child: GestureDetector(
                      onTap: isCommittedToSwipe ? null : onTap,
                      onPanStart: onPanStart,
                      onPanUpdate: onPanUpdate,
                      onPanEnd: onPanEnd,
                      child: FlashcardWidget(
                        card: card,
                        flipAnimation: flipAnimation,
                        isFlipped: isFlipped,
                        isBookmarked: isBookmarked,
                        onBookmarkPressed: onBookmarkPressed,
                      ),
                    ),
                  )
                else
                  FlashcardWidget(
                    card: card,
                    flipAnimation: flipAnimation,
                    isFlipped: false,
                    isBookmarked: isBookmarked,
                    onBookmarkPressed: onBookmarkPressed,
                  ),

                // Indicator màu khi quẹt
                if (isCurrentCard &&
                    isDragging &&
                    (dragOffset.abs() > FlashcardConstants.minSwipeDistance ||
                        dragOffsetY.abs() >
                            FlashcardConstants.minSwipeDistance))
                  _buildSwipeIndicator(context),

                // Icon quẹt trái/phải
                if (isCurrentCard &&
                    isDragging &&
                    isCommittedToSwipe &&
                    (dragOffset.abs() > FlashcardConstants.iconSwipeDistance ||
                        dragOffsetY.abs() >
                            FlashcardConstants.iconSwipeDistance))
                  _buildSwipeIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateOpacity() {
    if (isDragging &&
        (dragOffset.abs() > FlashcardConstants.minSwipeDistance ||
            dragOffsetY.abs() > FlashcardConstants.minSwipeDistance)) {
      return (1.0 -
              ((dragOffset.abs() + dragOffsetY.abs()) /
                  FlashcardConstants.opacityDivisor))
          .clamp(0.0, 1.0);
    }
    return 1.0;
  }

  Widget _buildSwipeIndicator(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dragOffset > 0
            ? (isCommittedToSwipe
                  ? Colors.green.withOpacity(0.4)
                  : Colors.green.withOpacity(0.2))
            : (isCommittedToSwipe
                  ? Colors.red.withOpacity(0.4)
                  : Colors.red.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildSwipeIcon() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isCommittedToSwipe ? 1.0 : 0.0,
        child: Icon(
          dragOffset > 0 ? Icons.check_circle : Icons.cancel,
          size: isCommittedToSwipe ? 100 : 80,
          color: dragOffset > 0 ? Colors.green.shade600 : Colors.red.shade600,
        ),
      ),
    );
  }
}
