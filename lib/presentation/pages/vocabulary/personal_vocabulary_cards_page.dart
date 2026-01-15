// lib/presentation/pages/vocabulary/personal_vocabulary_cards_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/domain/entities/vocabulary_card.dart';
import '../../providers/personal_vocabulary_provider.dart';
import '../../widgets/vocabulary/vocabulary_card_widget.dart';

/// Page hiển thị chi tiết các thẻ từ vựng đã bookmark theo chủ đề
class PersonalVocabularyCardsPage extends StatefulWidget {
  final String topicId;

  const PersonalVocabularyCardsPage({
    super.key,
    required this.topicId,
  });

  @override
  State<PersonalVocabularyCardsPage> createState() =>
      _PersonalVocabularyCardsPageState();
}

class _PersonalVocabularyCardsPageState
    extends State<PersonalVocabularyCardsPage> {
  
  // Topic metadata
  final Map<String, Map<String, String>> _topicMetadata = {
    'food': {
      'emoji': '🍔',
      'name': 'Food & Drinks',
      'description': 'Từ vựng về đồ ăn và đồ uống',
    },
    'business': {
      'emoji': '💼',
      'name': 'Business & Economics',
      'description': 'Từ vựng về kinh doanh và kinh tế',
    },
    'technology': {
      'emoji': '💻',
      'name': 'Technology',
      'description': 'Từ vựng về công nghệ',
    },
    'travel': {
      'emoji': '✈️',
      'name': 'Travel',
      'description': 'Từ vựng về du lịch',
    },
    'health': {
      'emoji': '🏥',
      'name': 'Health',
      'description': 'Từ vựng về sức khỏe',
    },
    'education': {
      'emoji': '📚',
      'name': 'Education',
      'description': 'Từ vựng về giáo dục',
    },
    'nature': {
      'emoji': '🌳',
      'name': 'Nature & Environment',
      'description': 'Từ vựng về thiên nhiên',
    },
  };

  @override
  Widget build(BuildContext context) {
    final metadata = _topicMetadata[widget.topicId];
    final topicName = metadata?['name'] ?? 'Unknown Topic';

    return MainLayout(
      title: topicName.toUpperCase(),
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: kBackgroundColor),
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: spaceMd,
                vertical: spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        metadata?['emoji'] ?? '📖',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topicName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer<PersonalVocabularyProvider>(
                              builder: (context, provider, child) {
                                final topicCards =
                                    _getCardsForTopic(provider, widget.topicId);
                                return Text(
                                  '${topicCards.length} từ đã lưu',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: kTextSecondary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Cards grid
            Expanded(
              child: Consumer<PersonalVocabularyProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final topicCards = _getCardsForTopic(provider, widget.topicId);

                  if (topicCards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 80,
                            color: kTextThird,
                          ),
                          const SizedBox(height: spaceMd),
                          Text(
                            'Chưa có từ nào trong chủ đề này',
                            style: TextStyle(
                              fontSize: 16,
                              color: kTextSecondary,
                            ),
                          ),
                          const SizedBox(height: spaceSm),
                          Text(
                            'Nhấn dấu sao ⭐ để lưu từ vựng',
                            style: TextStyle(
                              fontSize: 14,
                              color: kTextThird,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: spaceMd,
                      vertical: spaceSm,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: spaceMd,
                      mainAxisSpacing: spaceMd,
                    ),
                    itemCount: topicCards.length,                    itemBuilder: (context, index) {
                      final card = topicCards[index];
                      return VocabularyCardWidget(
                        card: card,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Get all cards for the specific topic
  List<VocabularyCard> _getCardsForTopic(
    PersonalVocabularyProvider provider,
    String topicId,
  ) {
    return provider.personalCards.where((card) {
      final cardTopicId = _extractTopicId(card.id);
      return cardTopicId == topicId;
    }).toList();
  }

  /// Extract topic ID from card ID (e.g., "food_1" -> "food")
  String? _extractTopicId(String cardId) {
    if (cardId.contains('_')) {
      return cardId.split('_').first;
    }
    return null;
  }
}
