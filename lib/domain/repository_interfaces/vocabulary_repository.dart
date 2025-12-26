// lib/domain/repository_interfaces/vocabulary_repository.dart

import '../entities/vocabulary_card.dart';
import '../entities/vocabulary_topic.dart';

abstract class VocabularyRepository {
  // Topic operations
  Future<List<VocabularyTopic>> getVocabularyTopics();
  Future<VocabularyTopic?> getVocabularyTopicById(String topicId);
  Future<void> createVocabularyTopic(VocabularyTopic topic);
  Future<void> updateVocabularyTopic(VocabularyTopic topic);
  Future<void> deleteVocabularyTopic(String topicId);

  // Card operations
  Future<List<VocabularyCard>> getVocabularyCards(String topicId);
  Future<VocabularyCard?> getVocabularyCardById(String cardId);
  Future<void> createVocabularyCard(String topicId, VocabularyCard card);
  Future<void> updateVocabularyCard(VocabularyCard card);
  Future<void> deleteVocabularyCard(String cardId);

  // Search operations
  Future<List<VocabularyCard>> searchVocabularyCards(String query);
  Future<List<VocabularyTopic>> searchVocabularyTopics(String query);
}
