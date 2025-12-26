// lib/presentation/pages/vocabulary/vocab_menu_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import '../../widgets/vocab_menu_item.dart';
import '../../providers/vocabulary_provider.dart';
import '../../../domain/entities/vocabulary_card.dart';
import 'dart:math' as math;

class VocabMenuPage extends StatefulWidget {
  final String? topicId;

  const VocabMenuPage({super.key, this.topicId});

  @override
  State<VocabMenuPage> createState() => _VocabMenuPageState();
}

class _VocabMenuPageState extends State<VocabMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85, // Để thấy một phần card bên cạnh
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 10),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
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
    _pageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabularyProvider>(
      builder: (context, vocabularyProvider, child) {
        if (vocabularyProvider.isLoading) {
          return MainLayout(
            title: 'VOCABULARY',
            currentIndex: -1,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (vocabularyProvider.error != null) {
          return MainLayout(
            title: 'VOCABULARY',
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
            title: 'VOCABULARY',
            currentIndex: -1,
            child: const Center(
              child: Text(
                'Không có từ vựng nào',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        return MainLayout(
          title: 'VOCABULARY',
          currentIndex: -1,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: kBackgroundColor),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: spaceMd),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.only(right: 25),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: kIconBackColor,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            padding: const EdgeInsets.only(left: 25),
                            icon: const Icon(
                              Icons.more_vert,
                              color: kIconBackColor,
                              size: 30,
                            ),
                            onPressed: () {
                              print('Navigate more');
                            },
                          ),
                        ],
                      ),

                      // Card "Từ vựng" với dots - có thể lật và lướt ngang
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            vocabularyProvider.setCurrentCardIndex(index);
                            // Reset animation state
                            _animationController.reset();
                          },
                          itemCount: vocabularyCards.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: _buildVocabularyCard(
                                context,
                                vocabularyCards[index],
                                index,
                                vocabularyProvider,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dots indicator cho PageView - giới hạn 4 dots
                      _buildDotsIndicator(vocabularyProvider),

                      const SizedBox(height: spaceLg),

                      // "Tên Chủ Đề" title
                      const Text(
                        'Tên Chủ Đề',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),

                      const SizedBox(height: spaceMd),

                      // Profile section
                      _buildProfileSection(vocabularyCards.length),

                      const SizedBox(height: spaceLg),

                      // Menu items
                      _buildMenuItems(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVocabularyCard(
    BuildContext context,
    VocabularyCard card,
    int index,
    VocabularyProvider provider,
  ) {
    return GestureDetector(
      onTap: () => _flipCard(),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_flipAnimation.value * math.pi),
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
                          ? Text(
                              card.vietnamese,
                              style: kFlashcardText,
                              textAlign: TextAlign.center,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  card.english,
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
                            ),
                    ),
                  ),
                  // Expand button (bottom right) - chỉ hiện ở mặt trước
                  if (isShowingFront)
                    Positioned(
                      bottom: 4,
                      right: 0,
                      child: TextButton(
                        onPressed: () =>
                            print('Expand vocabulary card ${index + 1}'),
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

  Widget _buildDotsIndicator(VocabularyProvider provider) {
    final vocabularyCards = provider.vocabularyCards;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        vocabularyCards.length > 4 ? 4 : vocabularyCards.length,
        (index) {
          final dotIndex = provider.getDotIndex();
          final isActive = dotIndex == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 12 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? kTextPrimary : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(int cardCount) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: kSecondaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(width: spaceMd),
        // Name and terms count
        Text('Name', style: TextStyle(fontSize: 14, color: kTextThird)),
        const SizedBox(width: 45),
        Text(
          '$cardCount thuật ngữ',
          style: const TextStyle(
            fontSize: 14,
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        VocabMenuItem(
          icon: Icons.library_books_outlined,
          backgroundColor: kSurfaceColor,
          title: 'Thẻ ghi nhớ',
          iconColor: kIconFlashcardColor,
          onTap: () {
            print('Navigate to Flash Cards');
          },
        ),
        VocabMenuItem(
          icon: Icons.school_rounded,
          backgroundColor: kSurfaceColor,
          title: 'Học',
          iconColor: kIconFlashcardColor,
          onTap: () {
            print('Navigate to Learn');
          },
        ),
        VocabMenuItem(
          icon: Icons.quiz,
          backgroundColor: kSurfaceColor,
          title: 'Kiểm tra',
          iconColor: kIconFlashcardColor,
          onTap: () {
            print('Navigate to Test');
          },
        ),
        VocabMenuItem(
          icon: Icons.extension,
          backgroundColor: kSurfaceColor,
          title: 'Ghép thẻ',
          iconColor: kIconFlashcardColor,
          onTap: () {
            print('Navigate to Match');
          },
        ),
      ],
    );
  }
}
