// lib/presentation/pages/vocabulary/personal_vocabulary_by_topic_page.dart

import 'package:en_go_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import '../../widgets/topic_card.dart';
import '../../providers/personal_vocabulary_provider.dart';

/// Page hiển thị "Bộ từ của bạn" phân loại theo chủ đề
class PersonalVocabularyByTopicPage extends StatefulWidget {
  const PersonalVocabularyByTopicPage({super.key});

  @override
  State<PersonalVocabularyByTopicPage> createState() =>
      _PersonalVocabularyByTopicPageState();
}

class _PersonalVocabularyByTopicPageState
    extends State<PersonalVocabularyByTopicPage> {
  
  // Topic metadata
  final Map<String, Map<String, String>> _topicMetadata = {
    'food': {
      'emoji': '🍔',
      'name': 'Food & Drinks',
      'description': 'Từ vựng về đồ ăn và đồ uống',
      'image': 'assets/images/food_drinks.png',
    },
    'business': {
      'emoji': '💼',
      'name': 'Business & Economics',
      'description': 'Từ vựng về kinh doanh và kinh tế',
      'image': 'assets/images/business_economy.png',
    },
    'technology': {
      'emoji': '💻',
      'name': 'Technology',
      'description': 'Từ vựng về công nghệ',
      'image': 'assets/images/technology.png',
    },
    'travel': {
      'emoji': '✈️',
      'name': 'Travel',
      'description': 'Từ vựng về du lịch',
      'image': 'assets/images/travel.png',
    },
    'health': {
      'emoji': '🏥',
      'name': 'Health',
      'description': 'Từ vựng về sức khỏe',
      'image': 'assets/images/health.png',
    },
    'education': {
      'emoji': '📚',
      'name': 'Education',
      'description': 'Từ vựng về giáo dục',
      'image': 'assets/images/education.png',
    },
    'nature': {
      'emoji': '🌳',
      'name': 'Nature & Environment',
      'description': 'Từ vựng về thiên nhiên',
      'image': 'assets/images/nature_environment.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'BỘ TỪ CỦA BẠN',
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
                  Text(
                    'Bộ Từ Của Bạn',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: spaceSm),
                  Consumer<PersonalVocabularyProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        'Bạn đã lưu ${provider.cardCount} từ vựng',
                        style: TextStyle(
                          fontSize: 16,
                          color: kTextSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Topics list grouped by bookmarked cards
            Expanded(
              child: Consumer<PersonalVocabularyProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: kTextThird,
                          ),
                          const SizedBox(height: spaceMd),
                          Text(
                            'Không thể tải bộ từ của bạn',
                            style: TextStyle(
                              fontSize: 16,
                              color: kTextSecondary,
                            ),
                          ),
                          const SizedBox(height: spaceSm),
                          ElevatedButton(
                            onPressed: () {
                              provider.loadPersonalVocabulary();
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!provider.hasCards) {
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
                            'Chưa có từ nào được lưu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: kTextSecondary,
                            ),
                          ),
                          const SizedBox(height: spaceSm),
                          Text(
                            'Nhấn vào dấu sao ⭐ trên thẻ từ vựng\nđể lưu vào bộ từ của bạn',
                            style: TextStyle(
                              fontSize: 14,
                              color: kTextThird,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Group cards by topic
                  final cardsByTopic = _groupCardsByTopic(provider);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: spaceMd,
                      vertical: spaceSm,
                    ),
                    itemCount: cardsByTopic.length,
                    itemBuilder: (context, index) {
                      final topicEntry = cardsByTopic.entries.elementAt(index);
                      final topicId = topicEntry.key;
                      final cardCount = topicEntry.value;
                      final metadata = _topicMetadata[topicId];

                      if (metadata == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: spaceMd),
                        child: TopicCard(
                          title: metadata['name']!,
                          subtitle: metadata['description']!,
                          cardCount: cardCount,
                          emoji: metadata['emoji']!,
                          imageAsset: metadata['image']!,
                          onTap: () {
                            // Navigate to personal vocab cards by topic
                            Navigator.pushNamed(
                              context,
                              AppRoutes.personalVocabCards,
                              arguments: {'topicId': topicId},
                            );
                          },
                        ),
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

  /// Group personal cards by their topic ID
  Map<String, int> _groupCardsByTopic(PersonalVocabularyProvider provider) {
    final cardsByTopic = <String, int>{};
    
    for (final card in provider.personalCards) {
      // Extract topic ID from card ID (format: topicId_number)
      final topicId = _extractTopicId(card.id);
      if (topicId != null) {
        cardsByTopic[topicId] = (cardsByTopic[topicId] ?? 0) + 1;
      }
    }

    // Sort by card count (descending)
    final sortedEntries = cardsByTopic.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  /// Extract topic ID from card ID (e.g., "food_1" -> "food")
  String? _extractTopicId(String cardId) {
    if (cardId.contains('_')) {
      return cardId.split('_').first;
    }
    return null;
  }
}
