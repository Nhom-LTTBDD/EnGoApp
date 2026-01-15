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
  final bool isBookmarked; // Trạng thái bookmark
  final VoidCallback? onBookmarkPressed; // Callback khi nhấn bookmark

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
    this.isBookmarked = false,
    this.onBookmarkPressed,
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

        // Sound button - hiển thị cho cả flashcard và simple style ở mặt trước
        if (isShowingFront && onSoundPressed != null && card.audioUrl != null)
          Positioned(
            top: style == CardStyle.flashcard ? 16 : 8,
            left: style == CardStyle.flashcard ? 16 : 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSoundPressed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: style == CardStyle.flashcard
                        ? Colors.white.withOpacity(0.9)
                        : kSurfaceColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.volume_up,
                    size: style == CardStyle.flashcard ? 24 : 20,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
          ),

        // Bookmark button - hiển thị ở góc phải trên
        if (isShowingFront && onBookmarkPressed != null)
          Positioned(
            top: style == CardStyle.flashcard ? 16 : 8,
            right: style == CardStyle.flashcard ? 16 : 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBookmarkPressed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: style == CardStyle.flashcard
                        ? Colors.white.withOpacity(0.9)
                        : kSurfaceColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isBookmarked ? Icons.star : Icons.star_border,
                    size: style == CardStyle.flashcard ? 24 : 20,
                    color: isBookmarked ? Colors.amber : kTextThird,
                  ),
                ),
              ),
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
        // Hiển thị phonetic nếu có
        if (card.phonetic != null) ...[
          const SizedBox(height: 8),
          Text(
            card.phonetic!,
            style: TextStyle(
              fontSize: 16,
              color: kTextThird,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        // Hiển thị part of speech nếu có
        if (card.partsOfSpeech != null && card.partsOfSpeech!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            card.partsOfSpeech!.join(', '),
            style: TextStyle(
              fontSize: 14,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildBackContent() {
    if (style == CardStyle.simple) {
      // Simple style - hiển thị tiếng Việt + nghĩa + định nghĩa từ dictionary
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            // Hiển thị definition đầu tiên từ dictionary
            if (card.definitions != null && card.definitions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kSurfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.definitions!.first,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Flashcard style - hiển thị tiếng Việt + nghĩa + thông tin chi tiết từ dictionary
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
          const SizedBox(height: 12),
          Text(
            card.meaning,
            style: TextStyle(
              fontSize: 16,
              color: kTextThird,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          // Hiển thị definitions từ dictionary
          if (card.definitions != null && card.definitions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...card.definitions!.take(2).map((definition) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          definition,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          // Hiển thị examples từ dictionary
          if (card.examples != null && card.examples!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Examples:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            ...card.examples!.take(1).map((example) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '"$example"',
                    style: TextStyle(
                      fontSize: 13,
                      color: kTextThird,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ],
      ),
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
