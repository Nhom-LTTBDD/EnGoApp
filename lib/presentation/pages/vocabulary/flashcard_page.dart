// lib/presentation/pages/vocabulary/flashcard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/streak_provider.dart';
import '../../widgets/vocabulary/flashcard_header.dart';
import '../../widgets/vocabulary/flashcard_score_display.dart';
import '../../widgets/vocabulary/flashcard_swipe_card.dart';
import '../../widgets/vocabulary/flashcard_controls.dart';
import 'flashcard_result_page.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/flashcard_constants.dart';
import '../../../core/theme/theme_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadVocabularyCards();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: FlashcardConstants.flipAnimationDuration,
      ),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  void _loadVocabularyCards() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset flashcard state when entering the page
      context.read<FlashcardProvider>().resetAll();
      context.read<VocabularyProvider>().setCurrentCardIndex(0);
      context.read<VocabularyProvider>().resetCardFlip();

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

  void _showResultDialog() async {
    final flashcardProvider = context.read<FlashcardProvider>();

    // Record activity to update streak
    context.read<StreakProvider>().recordActivity();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardResultPage(
          correctCount: flashcardProvider.correctCount,
          wrongCount: flashcardProvider.wrongCount,
        ),
      ),
    );

    // Handle result from the result page
    if (result == 'go_back') {
      if (mounted) Navigator.of(context).pop(); // Go back to previous page
    } else if (result == 'study_again') {
      _resetAndStudyAgain();
    }
  }

  void _resetAndStudyAgain() {
    final flashcardProvider = context.read<FlashcardProvider>();
    final vocabProvider = context.read<VocabularyProvider>();

    flashcardProvider.resetAll();
    vocabProvider.setCurrentCardIndex(0);
    vocabProvider.resetCardFlip();
    _animationController.reset();
  }

  void _handleFlipCard() {
    final flashcardProvider = context.read<FlashcardProvider>();

    if (flashcardProvider.isCommittedToSwipe) return;

    flashcardProvider.toggleFlip();

    if (flashcardProvider.isFlipped) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handlePanStart(DragStartDetails details) {
    final flashcardProvider = context.read<FlashcardProvider>();

    if (!flashcardProvider.isCommittedToSwipe) {
      flashcardProvider.setDragging(false);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final flashcardProvider = context.read<FlashcardProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    if (!flashcardProvider.isCommittedToSwipe) {
      flashcardProvider.updateDragOffset(details.delta.dx, details.delta.dy);

      final totalDistance =
          (flashcardProvider.dragOffset.abs() +
          flashcardProvider.dragOffsetY.abs());

      if (totalDistance > FlashcardConstants.minDragDistance) {
        flashcardProvider.setDragging(true);
      }

      final commitThreshold =
          screenWidth * FlashcardConstants.commitSwipeThreshold;
      final horizontalDistance = flashcardProvider.dragOffset.abs();

      if (horizontalDistance > commitThreshold) {
        flashcardProvider.setCommittedToSwipe(true);
      }
    } else {
      flashcardProvider.updateDragOffset(details.delta.dx, details.delta.dy);

      final safeZoneThreshold =
          screenWidth * FlashcardConstants.safeZoneThreshold;
      final horizontalDistance = flashcardProvider.dragOffset.abs();

      if (horizontalDistance < safeZoneThreshold) {
        flashcardProvider.setCommittedToSwipe(false);
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final flashcardProvider = context.read<FlashcardProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    if (flashcardProvider.isCommittedToSwipe) {
      if (flashcardProvider.dragOffset > 0) {
        _animateAndSwipeRight();
      } else {
        _animateAndSwipeLeft();
      }
    } else {
      final halfScreenWidth =
          screenWidth * FlashcardConstants.halfScreenThreshold;
      final velocity = details.velocity.pixelsPerSecond;
      final totalVelocity = (velocity.dx.abs() + velocity.dy.abs());
      final horizontalDistance = flashcardProvider.dragOffset.abs();

      if (horizontalDistance > halfScreenWidth ||
          totalVelocity > FlashcardConstants.velocityThreshold) {
        flashcardProvider.setCommittedToSwipe(true);

        if (flashcardProvider.dragOffset > 0) {
          _animateAndSwipeRight();
        } else {
          _animateAndSwipeLeft();
        }
      } else {
        flashcardProvider.resetDrag();
      }
    }
  }

  void _animateAndSwipeRight() {
    final flashcardProvider = context.read<FlashcardProvider>();
    final vocabProvider = context.read<VocabularyProvider>();

    // Animate card flying out
    setState(() {
      flashcardProvider.setCommittedToSwipe(true);
    });

    Future.delayed(
      const Duration(milliseconds: FlashcardConstants.transitionDelay),
      () {
        if (mounted) {
          flashcardProvider.incrementCorrect();
          flashcardProvider.nextCard();
          flashcardProvider.resetFlip();
          flashcardProvider.resetDrag();

          vocabProvider.setCurrentCardIndex(flashcardProvider.currentCardIndex);
          _animationController.reset();
          vocabProvider.resetCardFlip();

          // Check if finished
          if (flashcardProvider.currentCardIndex >=
              vocabProvider.vocabularyCards.length) {
            Future.delayed(
              const Duration(milliseconds: FlashcardConstants.transitionDelay),
              () {
                if (mounted) _showResultDialog();
              },
            );
          }
        }
      },
    );
  }

  void _animateAndSwipeLeft() {
    final flashcardProvider = context.read<FlashcardProvider>();
    final vocabProvider = context.read<VocabularyProvider>();

    // Animate card flying out
    setState(() {
      flashcardProvider.setCommittedToSwipe(true);
    });

    Future.delayed(
      const Duration(milliseconds: FlashcardConstants.transitionDelay),
      () {
        if (mounted) {
          flashcardProvider.incrementWrong();
          flashcardProvider.nextCard();
          flashcardProvider.resetFlip();
          flashcardProvider.resetDrag();

          vocabProvider.setCurrentCardIndex(flashcardProvider.currentCardIndex);
          _animationController.reset();
          vocabProvider.resetCardFlip();

          // Check if finished
          if (flashcardProvider.currentCardIndex >=
              vocabProvider.vocabularyCards.length) {
            Future.delayed(
              const Duration(milliseconds: FlashcardConstants.transitionDelay),
              () {
                if (mounted) _showResultDialog();
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VocabularyProvider, FlashcardProvider>(
      builder: (context, vocabProvider, flashcardProvider, child) {
        // Loading state
        if (vocabProvider.isLoading) {
          return _buildLoadingState();
        }

        // Error state
        if (vocabProvider.error != null) {
          return _buildErrorState(vocabProvider);
        }

        // Empty state
        if (vocabProvider.vocabularyCards.isEmpty) {
          return _buildEmptyState();
        }

        // Main flashcard UI
        return _buildFlashcardUI(vocabProvider, flashcardProvider);
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      body: const SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildErrorState(VocabularyProvider provider) {
    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                style: TextStyle(color: getTextSecondary(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    provider.loadVocabularyCards(widget.topicId ?? '1'),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      body: SafeArea(
        child: Center(
          child: Text(
            'Không có từ vựng nào',
            style: TextStyle(fontSize: 18, color: getTextSecondary(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardUI(
    VocabularyProvider vocabProvider,
    FlashcardProvider flashcardProvider,
  ) {
    final vocabularyCards = vocabProvider.vocabularyCards;

    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(spaceMd),
          child: Column(
            children: [
              // Header
              FlashcardHeader(
                onClose: () => Navigator.pop(context),
                currentIndex: flashcardProvider.currentCardIndex,
                totalCards: vocabularyCards.length,
              ),

              const SizedBox(height: spaceSm),

              // Score display
              FlashcardScoreDisplay(
                correctCount: flashcardProvider.correctCount,
                wrongCount: flashcardProvider.wrongCount,
              ),

              const SizedBox(height: spaceLg),

              // Flashcard stack
              Expanded(
                child: Center(
                  child: Stack(
                    children: [
                      // White placeholder card
                      _buildPlaceholderCard(),

                      // All flashcards
                      ...vocabularyCards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final card = entry.value;
                        final isCurrentCard =
                            index == flashcardProvider.currentCardIndex;

                        return FlashcardSwipeCard(
                          card: card,
                          flipAnimation: _flipAnimation,
                          isFlipped: flashcardProvider.isFlipped,
                          isCurrentCard: isCurrentCard,
                          isDragging: flashcardProvider.isDragging,
                          isCommittedToSwipe:
                              flashcardProvider.isCommittedToSwipe,
                          dragOffset: flashcardProvider.dragOffset,
                          dragOffsetY: flashcardProvider.dragOffsetY,
                          onTap: _handleFlipCard,
                          onPanStart: _handlePanStart,
                          onPanUpdate: _handlePanUpdate,
                          onPanEnd: _handlePanEnd,
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: spaceLg),

              // Controls
              FlashcardControls(onReset: _resetAndStudyAgain),

              const SizedBox(height: spaceMd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      width: double.infinity,
      height: FlashcardConstants.cardHeight,
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(
          FlashcardConstants.cardBorderRadius,
        ),
        border: Border.all(color: getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: getTextPrimary(context).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
