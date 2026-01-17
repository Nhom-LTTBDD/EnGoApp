// lib/presentation/providers/personal_vocabulary_provider.dart

import 'package:flutter/foundation.dart';
import '../../core/services/personal_vocabulary_service.dart';
import '../../domain/entities/vocabulary_card.dart';
import '../../domain/repository_interfaces/vocabulary_repository.dart';
import '../../domain/repository_interfaces/dictionary_repository.dart';

/// Provider quản lý state của Personal Vocabulary.
///
/// **Responsibilities:**
/// - Quản lý danh sách card đã bookmark
/// - Load card data từ repositories
/// - Enrich card với dictionary data
/// - Handle UI state (loading, error)
class PersonalVocabularyProvider with ChangeNotifier {  final PersonalVocabularyService _service;
  final VocabularyRepository _vocabularyRepository;
  final DictionaryRepository _dictionaryRepository;  // State variables
  String _userId = 'default_user';
  List<String> _bookmarkedCardIds = [];
  List<VocabularyCard> _personalCards = [];
  bool _isLoading = false;
  String? _error;
  
  // Prevent race conditions
  bool _isCurrentlyLoading = false;  PersonalVocabularyProvider({
    required PersonalVocabularyService service,
    required VocabularyRepository vocabularyRepository,
    required DictionaryRepository dictionaryRepository,
  })  : _service = service,
        _vocabularyRepository = vocabularyRepository,
        _dictionaryRepository = dictionaryRepository {
    // DON'T load here - wait for real userId from setUserId()
    // Constructor runs BEFORE auth is ready, so userId would be 'default_user'
    _logInfo('🎯 PersonalVocabularyProvider initialized (waiting for userId)');
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
    if (_userId != userId) {
      _logInfo('🔄 PersonalVocabularyProvider: Switching user from $_userId to $userId');
      _userId = userId;
      loadPersonalVocabulary();
    } else {
      _logInfo('✅ PersonalVocabularyProvider: User ID already set to $userId');
    }
  }
  
  // Get current userId (for debugging)
  String get currentUserId => _userId;  // Load personal vocabulary
  Future<void> loadPersonalVocabulary() async {
    // Don't load with default user - wait for real userId
    if (_userId == 'default_user') {
      _logWarning('⚠️ Skipping load with default_user - waiting for real userId');
      return;
    }
    
    // Prevent race condition: Skip if already loading
    if (_isCurrentlyLoading) {
      _logWarning('⚠️ Load already in progress, skipping duplicate request');
      return;
    }
    
    try {
      _isCurrentlyLoading = true;
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logInfo('🔄 Loading personal vocabulary for user: $_userId');

      // Get bookmarked card IDs
      _bookmarkedCardIds = await _service.getBookmarkedCardIds(_userId);
      _logInfo('📚 Found ${_bookmarkedCardIds.length} bookmarked card IDs from service');
      _logInfo('📋 Card IDs: ${_bookmarkedCardIds.join(", ")}');

      // Load and enrich all cards
      _personalCards = [];
      var loadedCount = 0;
      var failedCount = 0;
      
      if (_bookmarkedCardIds.isNotEmpty) {
        for (var i = 0; i < _bookmarkedCardIds.length; i++) {
          final cardId = _bookmarkedCardIds[i];
          _logInfo('📖 Loading card ${i + 1}/${_bookmarkedCardIds.length}: $cardId');
          
          final card = await _loadAndEnrichCard(cardId);
          if (card != null) {
            _personalCards.add(card);
            loadedCount++;
            _logInfo('  ✅ Success: ${card.english}');
          } else {
            failedCount++;
            _logWarning('  ❌ Failed to load card: $cardId');
          }
        }
      }

      _isLoading = false;
      _isCurrentlyLoading = false;
      _logInfo('✨ Personal vocabulary loaded: $loadedCount cards (${failedCount} failed)');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isCurrentlyLoading = false;
      _logError('❌ Error loading personal vocabulary: $e');
      notifyListeners();
    }
  }

  // Check if card is bookmarked
  bool isBookmarked(String cardId) {
    return _bookmarkedCardIds.contains(cardId);
  }  // Toggle bookmark
  Future<void> toggleBookmark(String cardId) async {
    try {
      _logInfo('⭐ Toggling bookmark for card: $cardId');
      
      final isNowBookmarked = await _service.toggleBookmark(_userId, cardId);
        
      if (isNowBookmarked) {
        _logInfo('✅ Added to bookmarks: $cardId');
        // Added to bookmarks
        if (!_bookmarkedCardIds.contains(cardId)) {
          _bookmarkedCardIds.add(cardId);
          
          // Load and enrich card
          final card = await _loadAndEnrichCard(cardId);
          if (card != null) {
            _personalCards.add(card);
          }
        }
      } else {
        _logInfo('❌ Removed from bookmarks: $cardId');
        // Removed from bookmarks
        _bookmarkedCardIds.remove(cardId);
        _personalCards.removeWhere((card) => card.id == cardId);
      }

      _logInfo('📊 Total bookmarks: ${_bookmarkedCardIds.length}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _logError('❌ Error toggling bookmark: $e');
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

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================
  /// Load và enrich một card từ ID
  Future<VocabularyCard?> _loadAndEnrichCard(String cardId) async {
    try {
      _logInfo('    🔍 Fetching card from repository: $cardId');
      final card = await _vocabularyRepository.getVocabularyCardById(cardId);
      
      if (card == null) {
        _logWarning('    ⚠️ Card not found in repository: $cardId');
        return null;
      }
      
      _logInfo('    📦 Card found: ${card.english}');

      // Enrich card với dictionary data
      try {
        _logInfo('    🔄 Enriching card with dictionary data...');
        final enrichedCard = await _dictionaryRepository.enrichVocabularyCard(card);
        _logInfo('    ✅ Card enriched successfully with phonetic: ${enrichedCard.phonetic ?? "N/A"}');
        return enrichedCard;
      } catch (e) {
        // Nếu không enrich được, vẫn trả về card gốc
        _logWarning('    ⚠️ Could not enrich card ${card.english}, using original: $e');
        return card;
      }
    } catch (e) {
      _logError('    ❌ Error loading card $cardId: $e');
      _logError('    ❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // ============================================================================
  // LOGGING HELPERS
  // ============================================================================

  void _logInfo(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
