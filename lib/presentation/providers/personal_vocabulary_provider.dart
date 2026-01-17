// lib/presentation/providers/personal_vocabulary_provider.dart

import 'package:flutter/foundation.dart';
import '../../core/services/personal_vocabulary_service.dart';
import '../../domain/entities/vocabulary_card.dart';
import '../../domain/repository_interfaces/vocabulary_repository.dart';
import '../../domain/repository_interfaces/dictionary_repository.dart';

/// Provider quản lý state của Personal Vocabulary
class PersonalVocabularyProvider with ChangeNotifier {
  final PersonalVocabularyService _service;
  final VocabularyRepository _vocabularyRepository;
  final DictionaryRepository _dictionaryRepository;

  // Current user ID (sẽ get từ AuthProvider)
  String _userId = 'default_user';

  // List of bookmarked card IDs
  List<String> _bookmarkedCardIds = [];

  // List of actual vocabulary cards
  List<VocabularyCard> _personalCards = [];

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _error;
  PersonalVocabularyProvider({
    required PersonalVocabularyService service,
    required VocabularyRepository vocabularyRepository,
    required DictionaryRepository dictionaryRepository,
  }) : _service = service,
       _vocabularyRepository = vocabularyRepository,
       _dictionaryRepository = dictionaryRepository {
    // Load personal vocabulary when provider is created
    loadPersonalVocabulary();
  }

  // Getters
  List<String> get bookmarkedCardIds => _bookmarkedCardIds;
  List<VocabularyCard> get personalCards => _personalCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cardCount => _personalCards.length;
  bool get hasCards => _personalCards.isNotEmpty;

  // Get number of topics (extract unique topic IDs from card IDs)
  int get topicCount {
    final topicIds = _bookmarkedCardIds
        .map((cardId) => _extractTopicId(cardId))
        .where((topicId) => topicId != null)
        .toSet();
    return topicIds.length;
  }

  // Extract topic ID from card ID (format: topicId_cardNumber)
  String? _extractTopicId(String cardId) {
    final parts = cardId.split('_');
    if (parts.length >= 2) {
      // Return all parts except the last one (which is the card number)
      return parts.sublist(0, parts.length - 1).join('_');
    }
    return null;
  }

  // Set user ID
  void setUserId(String userId) {
    if (_userId != userId) {
      print(
        '🔄 PersonalVocabularyProvider: Switching user from $_userId to $userId',
      );
      _userId = userId;
      loadPersonalVocabulary();
    } else {
      print('✅ PersonalVocabularyProvider: User ID already set to $userId');
    }
  }

  // Get current userId (for debugging)
  String get currentUserId => _userId;

  // Load personal vocabulary
  Future<void> loadPersonalVocabulary() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Loading personal vocabulary for user: $_userId');

      // Get bookmarked card IDs
      _bookmarkedCardIds = await _service.getBookmarkedCardIds(_userId);
      print(
        '📚 Found ${_bookmarkedCardIds.length} bookmarked cards',
      ); // Get actual card data from all topics
      _personalCards = [];
      if (_bookmarkedCardIds.isNotEmpty) {
        for (final cardId in _bookmarkedCardIds) {
          final card = await _vocabularyRepository.getVocabularyCardById(
            cardId,
          );
          if (card != null) {
            // Enrich card with dictionary data (phonetic, definitions, etc.)
            try {
              final enrichedCard = await _dictionaryRepository
                  .enrichVocabularyCard(card);
              _personalCards.add(enrichedCard);
              print(
                '✅ Loaded & enriched card: ${enrichedCard.english} - ${enrichedCard.phonetic ?? "no phonetic"}',
              );
            } catch (e) {
              // Nếu không enrich được, vẫn thêm card gốc
              _personalCards.add(card);
              print('✅ Loaded card (no enrichment): ${card.english}');
            }
          }
        }
      }

      _isLoading = false;
      print(
        '✨ Personal vocabulary loaded successfully: ${_personalCards.length} cards',
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      print('❌ Error loading personal vocabulary: $e');
      notifyListeners();
    }
  }

  // Check if card is bookmarked
  bool isBookmarked(String cardId) {
    return _bookmarkedCardIds.contains(cardId);
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String cardId) async {
    try {
      print('⭐ Toggling bookmark for card: $cardId');

      final isNowBookmarked = await _service.toggleBookmark(_userId, cardId);
      if (isNowBookmarked) {
        print('✅ Added to bookmarks: $cardId');
        // Added to bookmarks
        if (!_bookmarkedCardIds.contains(cardId)) {
          _bookmarkedCardIds.add(cardId);

          // Load card data
          final card = await _vocabularyRepository.getVocabularyCardById(
            cardId,
          );
          if (card != null) {
            // Enrich card with dictionary data
            try {
              final enrichedCard = await _dictionaryRepository
                  .enrichVocabularyCard(card);
              _personalCards.add(enrichedCard);
              print(
                '📚 Card loaded & enriched: ${enrichedCard.english} - ${enrichedCard.phonetic ?? "no phonetic"}',
              );
            } catch (e) {
              // Nếu không enrich được, vẫn thêm card gốc
              _personalCards.add(card);
              print('📚 Card loaded (no enrichment): ${card.english}');
            }
          }
        }
      } else {
        print('❌ Removed from bookmarks: $cardId');
        // Removed from bookmarks
        _bookmarkedCardIds.remove(cardId);
        _personalCards.removeWhere((card) => card.id == cardId);
      }

      print('📊 Total bookmarks: ${_bookmarkedCardIds.length}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('❌ Error toggling bookmark: $e');
      notifyListeners();
    }
  }

  // Add card
  Future<void> addCard(String cardId) async {
    try {
      await _service.addCard(_userId, cardId);
      await loadPersonalVocabulary();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove card
  Future<void> removeCard(String cardId) async {
    try {
      await _service.removeCard(_userId, cardId);
      _bookmarkedCardIds.remove(cardId);
      _personalCards.removeWhere((card) => card.id == cardId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove multiple cards
  Future<void> removeCards(List<String> cardIds) async {
    try {
      for (final cardId in cardIds) {
        await _service.removeCard(_userId, cardId);
      }
      await loadPersonalVocabulary();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear all bookmarks
  Future<void> clearAll() async {
    try {
      await _service.clearAll(_userId);
      _bookmarkedCardIds.clear();
      _personalCards.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
