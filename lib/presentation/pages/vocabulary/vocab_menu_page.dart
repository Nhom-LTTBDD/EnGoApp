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
import '../../widgets/vocabulary/vocab_menu_items.dart';
import '../../widgets/vocabulary/vocab_page_header.dart';

class VocabMenuPage extends StatefulWidget {
  final String? topicId;

  const VocabMenuPage({super.key, this.topicId});

  @override
  State<VocabMenuPage> createState() => _VocabMenuPageState();
}

class _VocabMenuPageState extends State<VocabMenuPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction:
          0.85, // Giảm xuống 0.8 để tăng khoảng cách giữa các card
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
    _pageController.dispose();
    super.dispose();
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
                    padding: const EdgeInsets.symmetric(horizontal: spaceMd),                    children: [
                      // Header with back button
                      const VocabPageHeader(),

                      // Card "Từ vựng" với dots - có thể lật và lướt ngang
                      VocabularyCardList(
                        pageController: _pageController,
                        vocabularyCards: vocabularyCards,
                        provider: vocabularyProvider,
                        topicId: widget.topicId, // Truyền topicId
                      ),

                      const SizedBox(height: 16),                      // Dots indicator cho PageView
                      DotsIndicator(
                        totalDots: vocabularyCards.length,
                        activeDotIndex: vocabularyProvider.getDotIndex(),
                      ),

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
