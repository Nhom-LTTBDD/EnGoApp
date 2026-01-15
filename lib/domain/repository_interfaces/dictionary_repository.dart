// lib/domain/repository_interfaces/dictionary_repository.dart

import '../entities/vocabulary_card.dart';

abstract class DictionaryRepository {
  /// Get word definition and enrich vocabulary card with dictionary data
  /// Returns enriched VocabularyCard with phonetic, definitions, examples, etc.
  Future<VocabularyCard> enrichVocabularyCard(VocabularyCard card);
  
  /// Clear dictionary cache
  Future<void> clearCache();
}
