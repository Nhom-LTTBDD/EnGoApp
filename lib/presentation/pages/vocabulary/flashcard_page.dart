// lib/presentation/pages/vocabulary/flashcard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/flashcard_progress_provider.dart';
import '../../providers/profile/streak_provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';
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
  final String? topicName;

  const FlashcardPage({super.key, this.topicId, this.topicName});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  // Store the current cards being studied (for checking completion)
  List<dynamic> _currentCards = [];

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
      final progressProvider = context.read<FlashcardProgressProvider>();
      final userId = progressProvider.userId;
      final topicId = widget.topicId ?? '1';

      // Reset flashcard state when entering the page
      context.read<FlashcardProvider>().resetAll();
      context.read<VocabularyProvider>().setCurrentCardIndex(0);
      context.read<VocabularyProvider>().resetCardFlip();

      // Load vocabulary cards
      context.read<VocabularyProvider>().loadVocabularyCards(topicId);

      // Load progress if user is authenticated
      if (userId != 'default_user') {
        progressProvider.loadProgress(userId: userId, topicId: topicId);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showResultDialog() async {
    final flashcardProvider = context.read<FlashcardProvider>();
    final progressProvider = context.read<FlashcardProgressProvider>();
    final authProvider = context.read<AuthProvider>();

    // Get userId from FlashcardProgressProvider (already set by main.dart)
    final userId = progressProvider.userId;
    final topicId = widget.topicId ?? '1';

    print('[FLASHCARD] ========== SESSION ENDED ==========');
    print('[FLASHCARD] User ID: $userId');
    print('[FLASHCARD] Topic ID: $topicId');
    print('[FLASHCARD] Auth State: ${authProvider.state.runtimeType}');
    if (authProvider.state is Authenticated) {
      final user = (authProvider.state as Authenticated).user;
      print('[FLASHCARD] Auth User ID: ${user.id}');
      print('[FLASHCARD] Auth User Email: ${user.email}');
    }

    // Save progress if user is authenticated
    if (userId != 'default_user') {
      // Get tracked card IDs from FlashcardProvider
      final masteredCardIds = flashcardProvider.masteredCardIds.toList();
      final learningCardIds = flashcardProvider.learningCardIds.toList();

      print('[FLASHCARD] Mastered Cards: $masteredCardIds');
      print('[FLASHCARD] Learning Cards: $learningCardIds');
      print('[FLASHCARD] Saving to Firebase...');

      try {
        // Update progress in Firebase
        await progressProvider.updateCards(
          userId: userId,
          topicId: topicId,
          masteredCardIds: masteredCardIds,
          learningCardIds: learningCardIds,
        );

        print('[FLASHCARD] SAVED TO FIREBASE SUCCESSFULLY!');
        print('[FLASHCARD] Check Firebase Console:');
        print('[FLASHCARD] Collection: flashcard_progress');
        print('[FLASHCARD] Document ID: ${userId}_$topicId');

        // Update streak after saving progress
        final streakProvider = context.read<StreakProvider>();

        // Ensure StreakProvider has correct userId
        streakProvider.setUserId(userId);

        print('[FLASHCARD] Recording activity for streak...');
        try {
          final result = await streakProvider.recordActivity();
          if (result['increased'] == true) {
            print(
              '[FLASHCARD] 🔥 Streak increased: ${result['oldStreak']} → ${result['newStreak']}',
            );
          } else {
            print(
              '[FLASHCARD] ✅ Streak maintained: ${result['newStreak']} days',
            );
          }
        } catch (e) {
          print('[FLASHCARD] ⚠️ Error recording streak: $e');
        }
      } catch (e) {
        print('[FLASHCARD] ERROR SAVING TO FIREBASE: $e');
      }
    } else {
      print('[FLASHCARD] User not authenticated - skipping Firebase save');
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardResultPage(
          correctCount: flashcardProvider.correctCount,
          wrongCount: flashcardProvider.wrongCount,
          topicId: widget.topicId ?? '',
          topicName: widget.topicName ?? 'Vocabulary',
        ),
      ),
    );

    // Handle result from the result page
    if (result == 'go_back') {
      if (mounted) Navigator.of(context).pop(); // Go back to previous page
    } else if (result == 'study_again') {
      _resetAndStudyAgain();
    } else if (result == 'continue_learning') {
      // Continue learning with remaining cards (do nothing, just reload the page)
      if (mounted) {
        // Reset flashcard state to start from beginning of remaining cards
        flashcardProvider.resetAll();
        context.read<VocabularyProvider>().setCurrentCardIndex(0);
        context.read<VocabularyProvider>().resetCardFlip();
        _animationController.reset();

        // Trigger rebuild to show remaining cards
        setState(() {});
      }
    }
  }

  void _resetAndStudyAgain() {
    final flashcardProvider = context.read<FlashcardProvider>();
    final vocabProvider = context.read<VocabularyProvider>();
    final progressProvider = context.read<FlashcardProgressProvider>();
    final userId = progressProvider.userId;
    final topicId = widget.topicId ?? '1';

    flashcardProvider.resetAll();
    vocabProvider.setCurrentCardIndex(0);
    vocabProvider.resetCardFlip();
    _animationController.reset();

    // Reset progress in Firebase if user is authenticated
    if (userId != 'default_user') {
      progressProvider.resetProgress(userId: userId, topicId: topicId);
    }
  }

  void _handleUndo() {
    final flashcardProvider = context.read<FlashcardProvider>();
    final vocabProvider = context.read<VocabularyProvider>();

    final success = flashcardProvider.undoLastAction();

    if (success) {
      // Sync với VocabularyProvider
      vocabProvider.setCurrentCardIndex(flashcardProvider.currentCardIndex);
      vocabProvider.resetCardFlip();

      // Reset animation
      _animationController.reset();

      // Rebuild UI
      setState(() {});
    } else {
      // Không có gì để undo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có thẻ nào để quay lại'),
          duration: Duration(seconds: 1),
        ),
      );
    }
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
          // Get current card and mark as mastered
          final currentCard = _currentCards[flashcardProvider.currentCardIndex];
          flashcardProvider.markCardAsMastered(currentCard.id);

          flashcardProvider.incrementCorrect();
          flashcardProvider.nextCard();
          flashcardProvider.resetFlip();
          flashcardProvider.resetDrag();

          vocabProvider.setCurrentCardIndex(flashcardProvider.currentCardIndex);
          _animationController.reset();
          vocabProvider.resetCardFlip();

          // Check if finished (use _currentCards instead of all vocabulary cards)
          if (flashcardProvider.currentCardIndex >= _currentCards.length) {
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
          // Get current card and mark as learning
          final currentCard = _currentCards[flashcardProvider.currentCardIndex];
          flashcardProvider.markCardAsLearning(currentCard.id);

          flashcardProvider.incrementWrong();
          flashcardProvider.nextCard();
          flashcardProvider.resetFlip();
          flashcardProvider.resetDrag();

          vocabProvider.setCurrentCardIndex(flashcardProvider.currentCardIndex);
          _animationController.reset();
          vocabProvider.resetCardFlip();

          // Check if finished (use _currentCards instead of all vocabulary cards)
          if (flashcardProvider.currentCardIndex >= _currentCards.length) {
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
    return Consumer3<
      VocabularyProvider,
      FlashcardProvider,
      FlashcardProgressProvider
    >(
      builder:
          (context, vocabProvider, flashcardProvider, progressProvider, child) {
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

            // Filter cards based on progress (only show learning cards)
            final allCards = vocabProvider.vocabularyCards;
            final learningCardIds = progressProvider.getCardsToStudy();
            final cardsToStudy = learningCardIds.isEmpty
                ? allCards // If no progress, study all cards
                : allCards
                      .where((card) => learningCardIds.contains(card.id))
                      .toList();

            // If all cards are mastered, auto-reset and show all cards
            if (cardsToStudy.isEmpty && progressProvider.hasProgress) {
              // Auto reset progress to allow re-study
              final userId = progressProvider.userId;
              final topicId = widget.topicId ?? '1';

              if (userId != 'default_user') {
                // Reset progress in background
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<FlashcardProgressProvider>().resetProgress(
                    userId: userId,
                    topicId: topicId,
                  );
                  // Reset flashcard provider state
                  context.read<FlashcardProvider>().clearProgress();
                });
              }

              // Show all cards for re-study
              return _buildFlashcardUI(allCards, flashcardProvider);
            }

            // Main flashcard UI with filtered cards
            return _buildFlashcardUI(cardsToStudy, flashcardProvider);
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
    List<dynamic> vocabularyCards,
    FlashcardProvider flashcardProvider,
  ) {
    // Store current cards for completion checking
    _currentCards = vocabularyCards;

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
              FlashcardControls(
                onUndo: _handleUndo,
                canUndo: flashcardProvider.canUndo,
              ),

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
