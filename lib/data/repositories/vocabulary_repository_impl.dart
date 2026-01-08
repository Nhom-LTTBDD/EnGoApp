// lib/data/repositories/vocabulary_repository_impl.dart

import '../../domain/entities/vocabulary_card.dart';
import '../../domain/entities/vocabulary_topic.dart';
import '../../domain/repository_interfaces/vocabulary_repository.dart';
import '../models/vocabulary_card_model.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  // Mock data - trong thực tế sẽ kết nối với API hoặc Database
  static final List<VocabularyCardModel> _mockCards = [
    VocabularyCardModel(
      id: '1',
      vietnamese: 'Từ vựng',
      english: 'Vocabulary',
      meaning: 'Từ vựng, bộ từ vựng',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
    VocabularyCardModel(
      id: '2',
      vietnamese: 'Học tập',
      english: 'Study',
      meaning: 'Học, nghiên cứu',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
    ),
    VocabularyCardModel(
      id: '3',
      vietnamese: 'Kiến thức',
      english: 'Knowledge',
      meaning: 'Hiểu biết, kiến thức',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    VocabularyCardModel(
      id: '4',
      vietnamese: 'Giáo dục',
      english: 'Education',
      meaning: 'Sự giáo dục, học vấn',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
    ),
    VocabularyCardModel(
      id: '5',
      vietnamese: 'Trường học',
      english: 'School',
      meaning: 'Nhà trường, trường học',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    VocabularyCardModel(
      id: '6',
      vietnamese: 'Giáo viên',
      english: 'Teacher',
      meaning: 'Người dạy học',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    VocabularyCardModel(
      id: '7',
      vietnamese: 'Học sinh',
      english: 'Student',
      meaning: 'Người đang học tập',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<VocabularyTopic>> getVocabularyTopics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - trong thực tế sẽ fetch từ API
    return [
      VocabularyTopic(
        id: '1',
        name: 'Tên Chủ Đề',
        description: 'Mô tả chủ đề từ vựng',
        cards: _mockCards,
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<VocabularyTopic?> getVocabularyTopicById(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (topicId == '1') {
      return VocabularyTopic(
        id: '1',
        name: 'Tên Chủ Đề',
        description: 'Mô tả chủ đề từ vựng',
        cards: _mockCards,
        createdBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<List<VocabularyCard>> getVocabularyCards(String topicId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data - trong thực tế sẽ filter theo topicId
    return _mockCards;
  }

  @override
  Future<VocabularyCard?> getVocabularyCardById(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _mockCards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createVocabularyTopic(VocabularyTopic topic) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Implement create logic
  }

  @override
  Future<void> updateVocabularyTopic(VocabularyTopic topic) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Implement update logic
  }

  @override
  Future<void> deleteVocabularyTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Implement delete logic
  }

  @override
  Future<void> createVocabularyCard(String topicId, VocabularyCard card) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Implement create card logic
  }

  @override
  Future<void> updateVocabularyCard(VocabularyCard card) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implement update card logic
  }

  @override
  Future<void> deleteVocabularyCard(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Implement delete card logic
  }

  @override
  Future<List<VocabularyCard>> searchVocabularyCards(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Simple search implementation
    return _mockCards
        .where(
          (card) =>
              card.vietnamese.toLowerCase().contains(query.toLowerCase()) ||
              card.english.toLowerCase().contains(query.toLowerCase()) ||
              card.meaning.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<VocabularyTopic>> searchVocabularyTopics(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock search result
    if (query.toLowerCase().contains('chủ đề')) {
      return await getVocabularyTopics();
    }
    return [];
  }
}
