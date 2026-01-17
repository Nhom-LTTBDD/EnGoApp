// lib/domain/usecase/get_vocabulary_cards.dart

import '../../entities/vocabulary_card.dart';
import '../../repository_interfaces/vocabulary_repository.dart';

class GetVocabularyCards {
  final VocabularyRepository repository;

  const GetVocabularyCards(this.repository);

  Future<List<VocabularyCard>> call(String topicId) async {
    try {
      return await repository.getVocabularyCards(topicId);
    } catch (e) {
      throw Exception('Failed to get vocabulary cards: $e');
    }
  }
}
