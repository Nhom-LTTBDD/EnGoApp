// lib/presentation/providers/personal_vocabulary_provider.dart

import 'package:flutter/foundation.dart';
import '../../core/services/personal_vocabulary_service.dart';
import '../../domain/entities/vocabulary_card.dart';
import '../../domain/repository_interfaces/vocabulary_repository.dart';
import '../../domain/repository_interfaces/dictionary_repository.dart';

/// Provider quản lý state của Personal Vocabulary (Bộ từ của bạn)
///
/// **Chức năng chính:**
/// - Quản lý danh sách card IDs đã bookmark (lưu trong SharedPrefs + Firestore)
/// - Load vocabulary card data từ VocabularyRepository theo card IDs
/// - Enrich cards với dictionary data (phonetic, definitions, audio)
/// - Handle bookmark/unbookmark operations
/// - Manage UI state (loading, error)
///
/// **Dependencies:**
/// - PersonalVocabularyService: Sync bookmarks SharedPrefs ↔ Firestore
/// - VocabularyRepository: Load card data
/// - DictionaryRepository: Enrich với API data
class PersonalVocabularyProvider with ChangeNotifier {
  final PersonalVocabularyService _service;
  final VocabularyRepository _vocabularyRepository;
  final DictionaryRepository _dictionaryRepository; // State variables
  String _userId = 'default_user';
  List<String> _bookmarkedCardIds = [];
  List<VocabularyCard> _personalCards = [];
  bool _isLoading = false;
  bool _isCurrentlyLoading = false;
  String? _error;
  PersonalVocabularyProvider({
    required PersonalVocabularyService service,
    required VocabularyRepository vocabularyRepository,
    required DictionaryRepository dictionaryRepository,
  }) : _service = service,
       _vocabularyRepository = vocabularyRepository,
       _dictionaryRepository = dictionaryRepository;  // Note: Data will be loaded lazily when setUserId is called or when explicitly requested

  // Getters
  List<String> get bookmarkedCardIds => _bookmarkedCardIds;
  List<VocabularyCard> get personalCards => _personalCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cardCount => _personalCards.length;
  bool get hasCards => _personalCards.isNotEmpty;
  int get topicCount => _personalCards.length; // Number of word sets/cards
  
  /// Set user ID và trigger load personal vocabulary
  /// Chỉ load khi userId thay đổi để tránh duplicate requests
  void setUserId(String userId) {
    if (_userId != userId) {
      _logInfo(
        'PersonalVocabularyProvider: Switching user from $_userId to $userId',
      );
      _userId = userId;
      loadPersonalVocabulary();
    }    // Remove the "already set" log to reduce log spam
  }

  // Get current userId (for debugging)
  String get currentUserId => _userId; 
  
  /// Load personal vocabulary từ PersonalVocabularyService
  /// 
  /// **Flow:**
  /// 1. Get bookmarked card IDs từ service (SharedPrefs/Firestore)
  /// 2. Load chi tiết mỗi card từ VocabularyRepository (parallel)
  /// 3. Enrich cards với DictionaryRepository (definitions, audio, phonetic)
  /// 4. Update state và notify listeners
  /// 
  /// **Race Condition Prevention:** Skip nếu đang loading
  /// **Performance:** Load tất cả cards parallel thay vì sequential
  Future<void> loadPersonalVocabulary() async {
    // Don't load with default user - wait for real userId
    if (_userId == 'default_user') {
      _logWarning('Skipping load with default_user - waiting for real userId');
      return;
    }

    // Prevent race condition: Skip if already loading
    if (_isCurrentlyLoading) {
      _logWarning('Load already in progress, skipping duplicate request');
      return;
    }

    try {
      _isCurrentlyLoading = true;
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logInfo('Loading personal vocabulary for user: $_userId');

      // Get bookmarked card IDs
      _bookmarkedCardIds = await _service.getBookmarkedCardIds(_userId);
      _logInfo(
        'Found ${_bookmarkedCardIds.length} bookmarked card IDs from service',
      );
      _logInfo('Card IDs: ${_bookmarkedCardIds.join(", ")}');

      // Load and enrich all cards - PARALLEL loading for better performance
      _personalCards = [];
      var loadedCount = 0;
      var failedCount = 0;

      if (_bookmarkedCardIds.isNotEmpty) {
        // Load tất cả cards song song thay vì tuần tự
        final loadFutures = _bookmarkedCardIds.asMap().entries.map((entry) {
          final i = entry.key;
          final cardId = entry.value;
          _logInfo(
            'Loading card ${i + 1}/${_bookmarkedCardIds.length}: $cardId',
          );
          return _loadAndEnrichCard(cardId);
        });

        // Đợi tất cả load xong cùng lúc
        final results = await Future.wait(loadFutures);

        // Process results
        for (var i = 0; i < results.length; i++) {
          final card = results[i];
          final cardId = _bookmarkedCardIds[i];

          if (card != null) {
            _personalCards.add(card);
            loadedCount++;
            _logInfo('Success: ${card.english}');
          } else {
            failedCount++;
            _logWarning('Failed to load card: $cardId');
          }
        }
      }

      _isLoading = false;
      _isCurrentlyLoading = false;
      _logInfo(
        '✨ Personal vocabulary loaded successfully: ${_personalCards.length} cards',
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isCurrentlyLoading = false;
      _logError('Error loading personal vocabulary: $e');
      notifyListeners();    }
  }

  /// Kiểm tra một card đã được bookmark chưa
  /// Tham số: cardId - ID của card cần kiểm tra
  /// Trả về: true nếu đã bookmark, false nếu chưa
  bool isBookmarked(String cardId) {
    return _bookmarkedCardIds.contains(cardId);
  } 
  
  /// Toggle bookmark cho một card (thêm nếu chưa có, xóa nếu đã có)
  /// 
  /// **Flow:**
  /// 1. Call service để toggle trong SharedPrefs + Firestore
  /// 2. Update local state (_bookmarkedCardIds, _personalCards)
  /// 3. Notify listeners để UI update
  /// 
  /// **Side effects:**
  /// - Thêm card: Load và enrich card data nếu chưa có trong _personalCards
  /// - Xóa card: Remove khỏi _personalCards
  Future<void> toggleBookmark(String cardId) async {
    try {
      _logInfo('Toggling bookmark for card: $cardId');

      final isNowBookmarked = await _service.toggleBookmark(_userId, cardId);

      if (isNowBookmarked) {
        _logInfo('Added to bookmarks: $cardId');
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
        _logInfo('Removed from bookmarks: $cardId');
        // Removed from bookmarks
        _bookmarkedCardIds.remove(cardId);
        _personalCards.removeWhere((card) => card.id == cardId);
      }

      _logInfo('Total bookmarks: ${_bookmarkedCardIds.length}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _logError('Error toggling bookmark: $e');
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
      _logInfo('Fetching card from repository: $cardId');
      final card = await _vocabularyRepository.getVocabularyCardById(cardId);

      if (card == null) {
        _logWarning('Card not found in repository: $cardId');
        return null;
      }

      _logInfo('Card found: ${card.english}');

      // Enrich card với dictionary data
      try {
        _logInfo('Enriching card with dictionary data...');
        final enrichedCard = await _dictionaryRepository.enrichVocabularyCard(
          card,
        );
        _logInfo(
          ' enriched successfully with phonetic: ${enrichedCard.phonetic ?? "N/A"}',
        );
        return enrichedCard;
      } catch (e) {
        // Nếu không enrich được, vẫn trả về card gốc
        _logWarning(
          'Could not enrich card ${card.english}, using original: $e',
        );
        return card;
      }
    } catch (e) {
      _logError('Error loading card $cardId: $e');
      _logError('Stack trace: ${StackTrace.current}');
      return null;
    }
  }
  // ============================================================================
  // LOGGING HELPERS
  // ============================================================================

  void _logInfo(String message) {
    if (kDebugMode) {
      print('[PERSONAL_VOCAB] $message');
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      print('[PERSONAL_VOCAB] ⚠️ $message');
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      print('[PERSONAL_VOCAB] ❌ $message');
    }
  }
}
