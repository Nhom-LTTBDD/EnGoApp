// lib/presentation/pages/vocabulary/personal_vocabulary_by_topic_page.dart

import 'package:en_go_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
import 'package:en_go_app/core/utils/isolate_helpers.dart';
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
  Map<String, int>? _cachedCardsByTopic; // Cache kết quả
  bool _isGrouping = false; // Flag để tránh compute nhiều lần

  // Topic metadata - Sử dụng Firebase Storage URLs giống vocab_by_topic_page
  final Map<String, Map<String, String>> _topicMetadata = {
    'food': {
      'emoji': '🍔',
      'name': 'Food & Drinks',
      'description': 'Từ vựng về đồ ăn và đồ uống',
      'image':
          'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/food.png',
    },
    'business': {
      'emoji': '💼',
      'name': 'Business & Economics',
      'description': 'Từ vựng về kinh doanh và kinh tế',
      'image':
          'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/business.png',
    },
    'technology': {
      'emoji': '💻',
      'name': 'Technology',
      'description': 'Từ vựng về công nghệ',
      'image':
          'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/technology.png',
    },
    'travel': {
      'emoji': '✈️',
      'name': 'Travel',
      'description': 'Từ vựng về du lịch',
      'image':
          'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/travel.png',
    },
    'health': {
      'emoji': '🏥',
      'name': 'Health',
      'description': 'Từ vựng về sức khỏe',
      'image':
          'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/health.png',
    },
    'education': {
      'emoji': '📚',
      'name': 'Education',
      'description': 'Từ vựng về giáo dục',
      'image':
          'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/education.png',
    },
    'nature': {
      'emoji': '🌳',
      'name': 'Nature & Environment',
      'description': 'Từ vựng về thiên nhiên',
      'image':
          'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/nature.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'BỘ TỪ CỦA BẠN',
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: getBackgroundColor(context)),
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
                      color: getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: spaceSm),
                  Consumer<PersonalVocabularyProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        'Bạn đã lưu ${provider.cardCount} từ vựng',
                        style: TextStyle(
                          fontSize: 16,
                          color: getTextSecondary(context),
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: getTextThird(context),
                          ),
                          const SizedBox(height: spaceMd),
                          Text(
                            'Không thể tải bộ từ của bạn',
                            style: TextStyle(
                              fontSize: 16,
                              color: getTextSecondary(context),
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
                            color: getTextThird(context),
                          ),
                          const SizedBox(height: spaceMd),
                          Text(
                            'Chưa có từ nào được lưu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: getTextSecondary(context),
                            ),
                          ),
                          const SizedBox(height: spaceSm),
                          Text(
                            'Nhấn vào dấu sao ⭐ trên thẻ từ vựng\nđể lưu vào bộ từ của bạn',
                            style: TextStyle(
                              fontSize: 14,
                              color: getTextThird(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Group cards by topic using FutureBuilder để compute trong isolate
                  return FutureBuilder<Map<String, int>>(
                    future: _getCardsByTopic(provider),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final cardsByTopic = snapshot.data ?? {};

                      if (cardsByTopic.isEmpty) {
                        return const Center(child: Text('Không có dữ liệu'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: spaceMd,
                          vertical: spaceSm,
                        ),
                        itemCount: cardsByTopic.length,
                        itemBuilder: (context, index) {
                          final topicEntry = cardsByTopic.entries.elementAt(
                            index,
                          );
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
                              // Sử dụng imageUrl cho Firebase Storage (giống vocab_by_topic_page)
                              imageUrl: metadata['image']!,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get cards grouped by topic - sử dụng compute để tránh blocking UI
  Future<Map<String, int>> _getCardsByTopic(
    PersonalVocabularyProvider provider,
  ) async {
    // Return cached nếu có và không đang grouping
    if (_cachedCardsByTopic != null && !_isGrouping) {
      return _cachedCardsByTopic!;
    }

    // Avoid multiple concurrent compute calls
    if (_isGrouping) {
      return _cachedCardsByTopic ?? {};
    }

    _isGrouping = true;

    try {
      // Chạy grouping trong isolate
      final result = await groupCardsByTopic(provider.personalCards);
      _cachedCardsByTopic = result;
      return result;
    } finally {
      _isGrouping = false;
    }
  }
}
