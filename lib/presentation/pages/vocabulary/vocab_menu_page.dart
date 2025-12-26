// lib/presentation/pages/vocabulary/vocab_menu_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import '../../providers/vocabulary_provider.dart';
import '../../widgets/vocabulary/vocabulary_card_list.dart';
import '../../widgets/vocabulary/dots_indicator.dart';
import '../../widgets/vocabulary/profile_section.dart';
import '../../widgets/vocabulary/vocab_menu_items.dart';
import '../../widgets/vocabulary/vocab_page_header.dart';

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
      viewportFraction:
          0.85, // Giảm xuống 0.8 để tăng khoảng cách giữa các card
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

  void _handleEditVocabularySet() {
    // TODO: Navigate to edit vocabulary set page
    print('Edit vocabulary set');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng sửa bộ từ đang phát triển')),
    );
  }

  void _handleDeleteVocabularySet() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa bộ từ'),
          content: const Text('Bạn có chắc chắn muốn xóa bộ từ này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete functionality
                print('Delete vocabulary set confirmed');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã xóa bộ từ')));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
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
                      // Header with back and more buttons
                      VocabPageHeader(
                        onEdit: _handleEditVocabularySet,
                        onDelete: _handleDeleteVocabularySet,
                      ),

                      // Card "Từ vựng" với dots - có thể lật và lướt ngang
                      VocabularyCardList(
                        pageController: _pageController,
                        vocabularyCards: vocabularyCards,
                        provider: vocabularyProvider,
                        flipAnimation: _flipAnimation,
                        animationController: _animationController,
                        onFlipCard: _flipCard,
                      ),

                      const SizedBox(height: 16),

                      // Dots indicator cho PageView
                      DotsIndicator(
                        totalDots: vocabularyCards.length,
                        activeDotIndex: vocabularyProvider.getDotIndex(),
                      ),

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
                      ProfileSection(cardCount: vocabularyCards.length),

                      const SizedBox(height: spaceLg),

                      // Menu items
                      VocabMenuItems(topicId: widget.topicId),
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
}
