// lib/presentation/widgets/vocabulary/base_card_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../domain/entities/vocabulary_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum CardStyle {
  flashcard, // Style phức tạp cho flashcard page
  simple, // Style đơn giản cho vocabulary menu
}

class BaseCardWidget extends StatelessWidget {
  final VocabularyCard card;
  final Animation<double> flipAnimation;
  final bool isFlipped;
  final CardStyle style;
  final double? width;
  final double? height;
  final VoidCallback? onSoundPressed;
  final Widget? extraWidget; // Widget bổ sung (như nút fullscreen)

  const BaseCardWidget({
    super.key,
    required this.card,
    required this.flipAnimation,
    required this.isFlipped,
    required this.style,
    this.width,
    this.height,
    this.onSoundPressed,
    this.extraWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        final isShowingFront = flipAnimation.value < 0.5;
        final rotationAxis = style == CardStyle.flashcard ? 'Y' : 'X';
        final rotation = flipAnimation.value * math.pi;

        // Xử lý rotation khác nhau cho từng style
        Matrix4 transform = Matrix4.identity()..setEntry(3, 2, 0.001);

        if (rotationAxis == 'Y') {
          // Flashcard style - rotate Y
          transform = transform..rotateY(rotation);
        } else {
          // Simple style - rotate X
          transform = transform..rotateX(rotation);
        }

        // Tạo widget content với logic đảo text cho mặt sau
        Widget content = _buildCard(isShowingFront);

        // Nếu đang hiển thị mặt sau, cần flip lại text để đọc được
        if (!isShowingFront) {
          if (rotationAxis == 'Y') {
            // Với rotation Y, flip horizontally
            content = Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0),
              child: content,
            );
          } else {
            // Với rotation X, flip vertically
            content = Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(1.0, -1.0),
              child: content,
            );
          }
        }

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: content,
        );
      },
    );
  }

  Widget _buildCard(bool isShowingFront) {
    // Container cơ bản
    final container = Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: style == CardStyle.flashcard ? Colors.white : kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _getCardShadow(),
      ),
      child: _buildCardContent(isShowingFront),
    );

    return container;
  }

  Widget _buildCardContent(bool isShowingFront) {
    Widget content = Stack(
      children: [
        // Main content
        Center(child: _buildMainContent(isShowingFront)),

        // Sound button (chỉ cho flashcard style và mặt trước)
        if (style == CardStyle.flashcard &&
            isShowingFront &&
            onSoundPressed != null)
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              onPressed: onSoundPressed,
              icon: const Icon(Icons.volume_up, size: 24, color: Colors.grey),
            ),
          ),

        // Extra widget (như nút fullscreen)
        if (extraWidget != null && isShowingFront) extraWidget!,
      ],
    );

    // Gradient chỉ cho flashcard style
    if (style == CardStyle.flashcard) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kSurfaceColor,
              kSurfaceColor.withOpacity(0.95),
              kSurfaceColor.withOpacity(0.9),
            ],
          ),
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildMainContent(bool isShowingFront) {
    if (isShowingFront) {
      return _buildFrontContent();
    } else {
      return _buildBackContent();
    }
  }

  Widget _buildFrontContent() {
    // Cả hai style đều hiển thị tiếng Anh ở mặt trước
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.english,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: kTextPrimary,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBackContent() {
    if (style == CardStyle.simple) {
      // Simple style - hiển thị tiếng Việt + nghĩa ở mặt sau
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.vietnamese,
            style: kFlashcardText,
            textAlign: TextAlign.center,
          ),
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

    // Flashcard style - hiển thị tiếng Việt + nghĩa ở mặt sau
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.vietnamese,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: kTextPrimary,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            card.meaning,
            style: TextStyle(
              fontSize: 16,
              color: kTextThird,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  List<BoxShadow> _getCardShadow() {
    if (style == CardStyle.flashcard) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }
  }
}
