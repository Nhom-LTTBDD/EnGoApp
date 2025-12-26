// lib/presentation/widgets/vocabulary/vocabulary_card_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../domain/entities/vocabulary_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class VocabularyCardWidget extends StatelessWidget {
  final VocabularyCard card;
  final int index;
  final Animation<double> flipAnimation;
  final VoidCallback onTap;
  final VoidCallback? onExpand;

  const VocabularyCardWidget({
    super.key,
    required this.card,
    required this.index,
    required this.flipAnimation,
    required this.onTap,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: flipAnimation,
        builder: (context, child) {
          final isShowingFront = flipAnimation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(flipAnimation.value * math.pi),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: kRadiusMedium,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Content area - Front or Back
                  Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateX(isShowingFront ? 0 : math.pi),
                      child: isShowingFront
                          ? _buildFrontContent()
                          : _buildBackContent(),
                    ),
                  ),
                  // Expand button (bottom right) - chỉ hiện ở mặt trước
                  if (isShowingFront && onExpand != null)
                    Positioned(
                      bottom: 4,
                      right: 0,
                      child: TextButton(
                        onPressed: onExpand,
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.fullscreen,
                            size: 30,
                            color: kFullscreenButtonColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontContent() {
    return Text(
      card.vietnamese,
      style: kFlashcardText,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBackContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(card.english, style: kFlashcardText, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          card.meaning,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
