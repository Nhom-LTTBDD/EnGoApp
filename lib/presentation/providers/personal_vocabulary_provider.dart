// lib/presentation/providers/personal_vocabulary_provider.dart

import 'package:flutter/foundation.dart';
import '../../core/services/personal_vocabulary_service.dart';
import '../../domain/entities/vocabulary_card.dart';
import '../../domain/repository_interfaces/vocabulary_repository.dart';

/// Provider quản lý state của Personal Vocabulary
class PersonalVocabularyProvider with ChangeNotifier {
  final PersonalVocabularyService _service;
  final VocabularyRepository _vocabularyRepository;

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
  })  : _service = service,
        _vocabularyRepository = vocabularyRepository {
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

  // Set user ID
  void setUserId(String userId) {
    _userId = userId;
    loadPersonalVocabulary();
  }
  // Load personal vocabulary
  Future<void> loadPersonalVocabulary() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Loading personal vocabulary for user: $_userId');

      // Get bookmarked card IDs
      _bookmarkedCardIds = await _service.getBookmarkedCardIds(_userId);
      print('📚 Found ${_bookmarkedCardIds.length} bookmarked cards');

      // Get actual card data from all topics
      _personalCards = [];
      if (_bookmarkedCardIds.isNotEmpty) {
        for (final cardId in _bookmarkedCardIds) {
          final card = await _vocabularyRepository.getVocabularyCardById(cardId);
          if (card != null) {
            _personalCards.add(card);
            print('✅ Loaded card: ${card.english}');
          }
        }
      }

      _isLoading = false;
      print('✨ Personal vocabulary loaded successfully: ${_personalCards.length} cards');
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
          final card = await _vocabularyRepository.getVocabularyCardById(cardId);
          if (card != null) {
            _personalCards.add(card);
            print('📚 Card loaded: ${card.english}');
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
