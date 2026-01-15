// lib/domain/usecase/enrich_vocabulary_card.dart

import '../entities/vocabulary_card.dart';
import '../repository_interfaces/dictionary_repository.dart';

class EnrichVocabularyCard {
  final DictionaryRepository repository;

  const EnrichVocabularyCard(this.repository);

  Future<VocabularyCard> call(VocabularyCard card) async {
    try {
      return await repository.enrichVocabularyCard(card);
    } catch (e) {
      // If enrichment fails, return original card
      return card;
    }
  }
}
