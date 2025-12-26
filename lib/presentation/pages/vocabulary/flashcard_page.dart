// lib/presentation/pages/vocabulary/flashcard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../layout/main_layout.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/vocabulary/flashcard_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class FlashcardPage extends StatefulWidget {
  final String? topicId;

  const FlashcardPage({super.key, this.topicId});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load vocabulary cards when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VocabularyProvider>().loadVocabularyCards(
        widget.topicId ?? '1',
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    final provider = context.read<VocabularyProvider>();
    provider.flipCard();

    if (provider.isCardFlipped) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _nextCard() {
    final provider = context.read<VocabularyProvider>();
    if (_currentCardIndex < provider.vocabularyCards.length - 1) {
      setState(() {
        _currentCardIndex++;
      });
      provider.setCurrentCardIndex(_currentCardIndex);
      _animationController.reset();
      provider.resetCardFlip();
    }
  }

  void _previousCard() {
    final provider = context.read<VocabularyProvider>();
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
      });
      provider.setCurrentCardIndex(_currentCardIndex);
      _animationController.reset();
      provider.resetCardFlip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabularyProvider>(
      builder: (context, vocabularyProvider, child) {
        if (vocabularyProvider.isLoading) {
          return MainLayout(
            title: 'THẺ GHI NHỚ',
            currentIndex: -1,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (vocabularyProvider.error != null) {
          return MainLayout(
            title: 'THẺ GHI NHỚ',
            currentIndex: -1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: kFlashcardText.copyWith(color: Colors.red.shade400),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vocabularyProvider.error!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vocabularyProvider.loadVocabularyCards(
                      widget.topicId ?? '1',
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final vocabularyCards = vocabularyProvider.vocabularyCards;
        if (vocabularyCards.isEmpty) {
          return MainLayout(
            title: 'THẺ GHI NHỚ',
            currentIndex: -1,
            child: const Center(
              child: Text(
                'Không có từ vựng nào',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        final currentCard = vocabularyCards[_currentCardIndex];

        return MainLayout(
          title: 'THẺ GHI NHỚ',
          currentIndex: -1,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: kBackgroundColor),
            padding: const EdgeInsets.all(spaceMd),
            child: Column(
              children: [
                // Header with back button and progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: kIconBackColor,
                        size: 30,
                      ),
                    ),
                    Text(
                      '${_currentCardIndex + 1}/${vocabularyCards.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),

                const SizedBox(height: spaceLg),

                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentCardIndex + 1) / vocabularyCards.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    kPrimaryColor,
                  ),
                ),

                const SizedBox(height: spaceLg),

                // Flashcard
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: FlashcardWidget(
                        card: currentCard,
                        flipAnimation: _flipAnimation,
                        isFlipped: vocabularyProvider.isCardFlipped,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: spaceLg),

                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous button
                    ElevatedButton(
                      onPressed: _currentCardIndex > 0 ? _previousCard : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios, size: 16),
                          SizedBox(width: 4),
                          Text('Trước'),
                        ],
                      ),
                    ),

                    // Flip button
                    ElevatedButton(
                      onPressed: _flipCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            vocabularyProvider.isCardFlipped
                                ? Icons.flip_to_front
                                : Icons.flip_to_back,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vocabularyProvider.isCardFlipped
                                ? 'Mặt trước'
                                : 'Mặt sau',
                          ),
                        ],
                      ),
                    ),

                    // Next button
                    ElevatedButton(
                      onPressed: _currentCardIndex < vocabularyCards.length - 1
                          ? _nextCard
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Tiếp'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: spaceMd),
              ],
            ),
          ),
        );
      },
    );
  }
}
