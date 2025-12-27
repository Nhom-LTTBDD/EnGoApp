// lib/presentation/widgets/vocabulary/flashcard_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../domain/entities/vocabulary_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

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
    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        final isShowingFront = flipAnimation.value < 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(flipAnimation.value * math.pi),
          child: Container(
            width: double.infinity,
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: spaceMd),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kSurfaceColor, kSurfaceColor.withOpacity(0.9)],
                ),
              ),
              child: Stack(
                children: [
                  // Main content
                  Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateY(isShowingFront ? 0 : math.pi),
                      child: isShowingFront
                          ? _buildFrontContent()
                          : _buildBackContent(),
                    ),
                  ),

                  // Corner indicator
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isShowingFront
                            ? kPrimaryColor.withOpacity(0.1)
                            : kSecondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isShowingFront ? 'Tiếng Việt' : 'English',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isShowingFront
                              ? kPrimaryColor
                              : kSecondaryColor,
                        ),
                      ),
                    ),
                  ),

                  // Tap indicator
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Chạm để lật thẻ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrontContent() {
    return Padding(
      padding: const EdgeInsets.all(spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate,
            size: 48,
            color: kPrimaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: spaceLg),
          Text(
            card.vietnamese,
            style: kFlashcardText.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spaceMd),
          Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackContent() {
    return Padding(
      padding: const EdgeInsets.all(spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language,
            size: 48,
            color: kSecondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: spaceLg),
          Text(
            card.english,
            style: kFlashcardText.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spaceMd),
          Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: spaceMd),
          Text(
            card.meaning,
            style: const TextStyle(
              fontSize: 16,
              color: kTextSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
