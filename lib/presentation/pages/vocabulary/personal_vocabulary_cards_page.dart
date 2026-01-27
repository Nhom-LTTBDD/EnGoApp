// lib/presentation/pages/vocabulary/personal_vocabulary_cards_page.dart

/// # PersonalVocabularyCardsPage - Presentation Layer
/// 
/// **Purpose:** Page hiển thị danh sách cards đã bookmark của một topic cụ thể
/// **Key Features:**
/// - Filter personal cards theo topicId
/// - Hiển thị cards trong vertical scrollable list
/// - Mỗi card có flip animation và bookmark toggle
/// - Empty state khi chưa có cards cho topic
/// 
/// **Data Flow:**
/// ```
/// PersonalVocabularyProvider -> Filter by topicId -> VocabularyCardWidget list
/// ```

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
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
  /// Build UI với Consumer để lắng nghe PersonalVocabularyProvider
  /// 
  /// **Flow:**
  /// 1. Hiển thị header với topic name và emoji
  /// 2. Filter cards theo topicId
  /// 3. Hiển thị cards trong grid layout (2 columns)
  /// 4. Empty state nếu chưa có cards cho topic này
  @override
  Widget build(BuildContext context) {
    final metadata = _topicMetadata[widget.topicId];
    final topicName = metadata?['name'] ?? 'Unknown Topic';

    return MainLayout(
      title: topicName.toUpperCase(),
      currentIndex: -1,      child: Container(
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
                          children: [                            Text(
                              topicName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: getTextPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer<PersonalVocabularyProvider>(
                              builder: (context, provider, child) {
                                final topicCards =
                                    _getCardsForTopic(provider, widget.topicId);
                                return Text(
                                  '${topicCards.length} từ đã lưu',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: getTextSecondary(context),
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
                        children: [                          Icon(
                            Icons.star_border,
                            size: 80,
                            color: getTextThird(context),
                          ),
                          const SizedBox(height: spaceMd),
                          Text(
                            'Chưa có từ nào trong chủ đề này',
                            style: TextStyle(
                              fontSize: 16,
                              color: getTextSecondary(context),
                            ),
                          ),
                          const SizedBox(height: spaceSm),
                          Text(
                            'Nhấn dấu sao ⭐ để lưu từ vựng',
                            style: TextStyle(
                              fontSize: 14,
                              color: getTextThird(context),
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
  }  /// Lọc cards theo topicId từ provider
  /// 
  /// **Logic:** Extract topic từ card.id và so sánh với topicId
  List<VocabularyCard> _getCardsForTopic(
    PersonalVocabularyProvider provider,
    String topicId,
  ) {
    return provider.personalCards.where((card) {
      final cardTopicId = _extractTopicId(card.id);
      return cardTopicId == topicId;
    }).toList();
  }
  /// Extract topic ID từ card ID
  /// 
  /// **Format:** "food_1" -> "food", "technology_5" -> "technology"
  String? _extractTopicId(String cardId) {
    if (cardId.contains('_')) {
      return cardId.split('_').first;
    }
    return null;
  }
}
