// lib/data/repositories/dictionary_repository_impl.dart

import '../../domain/entities/vocabulary_card.dart';
import '../../domain/repository_interfaces/dictionary_repository.dart';
import '../datasources/dictionary_local_data_source.dart';
import '../datasources/dictionary_remote_data_source.dart';
import '../models/dictionary_model.dart';

class DictionaryRepositoryImpl implements DictionaryRepository {
  final DictionaryRemoteDataSource remoteDataSource;
  final DictionaryLocalDataSource localDataSource;

  const DictionaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<VocabularyCard> enrichVocabularyCard(VocabularyCard card) async {
    try {
      // First, try to get from cache
      DictionaryModel? dictionaryData = 
          await localDataSource.getCachedWordDefinition(card.english);

      // If not in cache or cache expired, fetch from API
      if (dictionaryData == null) {
        try {
          dictionaryData = await remoteDataSource.getWordDefinition(card.english);
          
          // Cache the result
          await localDataSource.cacheWordDefinition(dictionaryData);
        } on DictionaryNotFoundException {
          // Word not found in dictionary, return original card
          return card;
        } on DictionaryApiException {
          // API error, return original card
          return card;
        }
      }

      // Enrich vocabulary card with dictionary data
      return _enrichCard(card, dictionaryData);
    } catch (e) {
      // On any error, return the original card
      return card;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await localDataSource.clearCache();
    } catch (e) {
      // Silently fail
    }
  }

  /// Enrich vocabulary card with dictionary data
  VocabularyCard _enrichCard(VocabularyCard card, DictionaryModel dictionary) {
    // Extract all definitions
    final definitions = <String>[];
    final examples = <String>[];
    
    for (var meaning in dictionary.meanings) {
      for (var definition in meaning.definitions) {
        definitions.add(definition.definition);
        if (definition.example != null && definition.example!.isNotEmpty) {
          examples.add(definition.example!);
        }
      }
    }

    // Get parts of speech
    final partsOfSpeech = dictionary.meanings
        .map((m) => m.partOfSpeech)
        .toSet()
        .toList();

    // Use dictionary audio URL if card doesn't have one
    final audioUrl = card.audioUrl ?? dictionary.audioUrl;

    return VocabularyCard(
      id: card.id,
      vietnamese: card.vietnamese,
      english: card.english,
      meaning: card.meaning,
      imageUrl: card.imageUrl,
      audioUrl: audioUrl,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
      phonetic: dictionary.phonetic,
      definitions: definitions.isNotEmpty ? definitions : null,
      examples: examples.isNotEmpty ? examples : null,
      partsOfSpeech: partsOfSpeech.isNotEmpty ? partsOfSpeech : null,
    );
  }
}
