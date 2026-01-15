// lib/presentation/pages/vocabulary/vocab_by_topic_page.dart
import 'package:en_go_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/repository_interfaces/vocabulary_repository.dart';
import '../../../domain/entities/vocabulary_topic.dart';
import '../../widgets/topic_card.dart';

class VocabByTopicPage extends StatefulWidget {
  const VocabByTopicPage({super.key});

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

  // Icon mapping cho các topics
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'VOCABULARY TOPICS',
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
                children: [                  Text(
                    'Chọn Chủ Đề',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: getTextPrimary(context),
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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [                          Icon(
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
                                _topicsFuture =
                                    _vocabularyRepository.getVocabularyTopics();
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
                        children: [                          Icon(
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
                  }                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: spaceMd,
                      vertical: spaceSm,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      final emoji = _getTopicEmoji(topic.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: spaceMd),
                        child: TopicCard(
                          title: topic.name,
                          subtitle: topic.description,
                          cardCount: topic.cards.length,
                          emoji: emoji,
                          imageAsset: topic.imageUrl,
                          onTap: () {
                            // Navigate to vocab menu with topic
                            Navigator.pushNamed(
                              context,
                              AppRoutes.vocabMenu,
                              arguments: {'topicId': topic.id},
                            );
                          },
                        ),
                      );
                    },
                  );},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
