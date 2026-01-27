// lib/presentation/pages/vocabulary/vocab_by_topic_page.dart

/// # VocabByTopicPage - Presentation Layer
/// 
/// **Purpose:** Page hiển thị danh sách topics để chọn học Flashcard hoặc Quiz
/// **Architecture Layer:** Presentation (UI)
/// **Key Features:**
/// - Dual-mode: Flashcard hoặc Quiz
/// - Hiển thị danh sách topics với ảnh từ Firebase Storage
/// - Navigate đến flashcard hoặc quiz settings tùy mode
/// - Loading, error, empty states
/// 
/// **Data Flow:**
/// ```
/// VocabularyRepository -> FutureBuilder -> TopicCard -> Navigation
/// ```

import 'package:en_go_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/repository_interfaces/vocabulary_repository.dart';
import '../../../domain/entities/vocabulary_topic.dart';
import '../../widgets/topic_card.dart';

/// Enum để phân biệt chế độ sử dụng của page
enum TopicSelectionMode {
  flashcard, // Học flashcard
  quiz, // Làm quiz
}

/// Page chọn topic - có thể dùng cho Flashcard hoặc Quiz
class VocabByTopicPage extends StatefulWidget {
  final TopicSelectionMode mode;

  const VocabByTopicPage({
    super.key,
    this.mode = TopicSelectionMode
        .flashcard, // Mặc định là flashcard để tương thích ngược
  });

  @override
  State<VocabByTopicPage> createState() => _VocabByTopicPageState();
}

class _VocabByTopicPageState extends State<VocabByTopicPage> {
  late Future<List<VocabularyTopic>> _topicsFuture;
  final _vocabularyRepository = GetIt.instance<VocabularyRepository>();
  @override
  void initState() {
    super.initState();
    _topicsFuture = _vocabularyRepository.getVocabularyTopics();
  }

  /// Lấy emoji icon tương ứng với topic ID
  /// 
  /// **Tham số:**
  /// - topicId: ID của topic
  /// 
  /// **Trả về:** Emoji string (mặc định là 📖)
  String _getTopicEmoji(String topicId) {
    switch (topicId) {
      case 'food':
        return '🍔';
      case 'business':
        return '💼';
      case 'technology':
        return '💻';
      case 'travel':
        return '✈️';
      case 'health':
        return '🏥';
      case 'education':
        return '📚';
      case 'nature':
        return '🌳';
      default:
        return '📖';
    }
  }
  /// Build UI với dynamic title/subtitle tùy theo mode (Flashcard/Quiz)
  /// 
  /// **Flow:**
  /// 1. Set title/subtitle khác nhau cho từng mode
  /// 2. Load topics từ repository (FutureBuilder)
  /// 3. Hiển thị danh sách TopicCard
  /// 4. Navigate đến flashcard hoặc quiz settings khi tap
  @override
  Widget build(BuildContext context) {
    // Dynamic title và subtitle dựa vào mode
    final String pageTitle = widget.mode == TopicSelectionMode.flashcard
        ? 'VOCABULARY TOPICS'
        : 'QUIZ BY TOPIC';

    final String headerTitle = widget.mode == TopicSelectionMode.flashcard
        ? 'Chọn Chủ Đề'
        : 'Chọn Chủ Đề Quiz';

    final String headerSubtitle = widget.mode == TopicSelectionMode.flashcard
        ? 'Chọn chủ đề để học flashcard'
        : 'Chọn chủ đề để làm bài kiểm tra';

    return MainLayout(
      title: pageTitle,
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
                    headerTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: spaceSm),
                  Text(
                    headerSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: getTextThird(context),
                    ),
                  ),
                ],
              ),
            ),

            // Topics list
            Expanded(
              child: FutureBuilder<List<VocabularyTopic>>(
                future: _topicsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
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
                            'Không thể tải danh sách chủ đề',
                            style: TextStyle(
                              fontSize: 16,
                              color: getTextSecondary(context),
                            ),
                          ),
                          const SizedBox(height: spaceSm),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _topicsFuture = _vocabularyRepository
                                    .getVocabularyTopics();
                              });
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final topics = snapshot.data ?? [];

                  if (topics.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: getTextThird(context),
                          ),
                          const SizedBox(height: spaceMd),
                          Text(
                            'Chưa có chủ đề nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: spaceMd,
                      vertical: spaceSm,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      final emoji = _getTopicEmoji(topic.id);                      return Padding(
                        padding: const EdgeInsets.only(bottom: spaceMd),
                        child: TopicCard(
                          title: topic.name,
                          subtitle: topic.description,
                          cardCount: topic.cards.length,
                          emoji: emoji,
                          // Use imageUrl for Firebase Storage, fallback to imageAsset for local
                          imageUrl: (topic.imageUrl != null && topic.imageUrl!.startsWith('http')) ? topic.imageUrl : null,
                          imageAsset: (topic.imageUrl != null && !topic.imageUrl!.startsWith('http')) ? topic.imageUrl : null,
                          onTap: () {
                            // Navigate dựa vào mode
                            if (widget.mode == TopicSelectionMode.flashcard) {
                              // Mode Flashcard: Navigate to flashcard page
                              Navigator.pushNamed(
                                context,
                                AppRoutes.flashcard,
                                arguments: {
                                  'topicId': topic.id,
                                  'topicName': topic.name,
                                },
                              );
                            } else {
                              // Mode Quiz: Navigate to quiz settings page
                              Navigator.pushNamed(
                                context,
                                AppRoutes.quizSettings,
                                arguments: {
                                  'topicId': topic.id,
                                  'topicName': topic.name,
                                  'cardCount': topic.cards.length,
                                  'mode': widget.mode,
                                },
                              );
                            }
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
}
