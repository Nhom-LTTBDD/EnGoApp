// lib/presentation/providers/vocabulary_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/vocabulary_card.dart';
import '../../domain/usecases/vocabulary/get_vocabulary_cards.dart';
import '../../domain/usecases/vocabulary/enrich_vocabulary_card.dart';

/// Provider quản lý state của Vocabulary Cards (learning mode)
///
/// **Chức năng chính:**
/// - Load vocabulary cards theo topic từ repository
/// - Enrich cards với dictionary data (definitions, audio, phonetic)
/// - Quản lý navigation giữa các cards (swipe left/right)
/// - Quản lý flip state của flashcards (xem mặt trước/sau)
/// - Xử lý dots indicator logic (4-dot asymmetric system)
///
/// **State Management:** ChangeNotifier pattern
/// **Use Cases:** GetVocabularyCards, EnrichVocabularyCard
class VocabularyProvider extends ChangeNotifier {
  final GetVocabularyCards getVocabularyCards;
  final EnrichVocabularyCard enrichVocabularyCard;

  VocabularyProvider({
    required this.getVocabularyCards,
    required this.enrichVocabularyCard,
  });

  // ============================================================================
  // STATE
  // ============================================================================

  String? _currentTopicId; // Track current topic to detect changes
  List<VocabularyCard> _vocabularyCards = [];
  bool _isLoading = false;
  String? _error;
  int _currentCardIndex = 0;
  int _previousCardIndex = 0;
  bool _isCardFlipped = false;
  Map<int, bool> _cardFlipStates =
      {}; // ============================================================================
  // GETTERS
  // ============================================================================

  List<VocabularyCard> get vocabularyCards => _vocabularyCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentCardIndex => _currentCardIndex;
  int get previousCardIndex => _previousCardIndex;
  bool get isCardFlipped => _isCardFlipped;

  /// Get flip state for specific card index
  bool isCardFlippedAtIndex(int index) {
    return _cardFlipStates[index] ?? false;
  }

  /// Get current card being displayed
  VocabularyCard? get currentCard {
    if (_vocabularyCards.isEmpty ||
        _currentCardIndex >= _vocabularyCards.length) {
      return null;
    }
    return _vocabularyCards[_currentCardIndex];
  }

  /// Check if user is swiping forward (left to right)  /// Check if user is swiping forward (left to right)
  bool get isSwipingForward => _currentCardIndex > _previousCardIndex;
  // ============================================================================
  // PUBLIC METHODS - Load Cards
  // ============================================================================

  /// Load vocabulary cards cho một topic cụ thể và enrich với dictionary data
  /// 
  /// **Flow:**
  /// 1. Clear old cards nếu topic thay đổi
  /// 2. Call use case GetVocabularyCards để load từ repository
  /// 3. Enrich mỗi card với dictionary API (definitions, audio, phonetic)
  /// 4. Update state và notify listeners
  /// 
  /// **Tham số:** topicId - ID của topic (vd: 'food', 'business')
  /// **Error handling:** Catch exception và set error state
  Future<void> loadVocabularyCards(String topicId) async {
    // If topic changed, clear old cards first
    if (_currentTopicId != null && _currentTopicId != topicId) {
      _logInfo(
        'Topic changed from $_currentTopicId to $topicId, clearing old cards',
      );
      clearCards();
    }
    _currentTopicId = topicId;

    _setLoading(true);
    _setError(null);

    try {
      _logInfo('Loading vocabulary cards for topic: $topicId');
      final cards = await getVocabularyCards.call(topicId);
      _logInfo('Loaded ${cards.length} cards');

      // Enrich cards with dictionary data
      final enrichedCards = await _enrichCards(cards);

      _vocabularyCards = enrichedCards;
      _resetNavigationState();
      _logInfo(
        'Vocabulary cards loaded successfully: ${enrichedCards.length} cards',
      );

      notifyListeners();
    } catch (e) {
      _logError('Error loading vocabulary cards: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  // ============================================================================
  // PUBLIC METHODS - Navigation
  // ============================================================================

  /// Set card index hiện tại để navigate giữa các cards
  /// 
  /// **Tham số:** index - Index của card cần hiển thị (0-based)
  /// **Validation:** Chỉ cho phép index trong range hợp lệ
  /// **Side effect:** Reset flip state khi chuyển card
  void setCurrentCardIndex(int index) {
    if (index >= 0 && index < _vocabularyCards.length) {
      _previousCardIndex = _currentCardIndex;
      _currentCardIndex = index;
      _isCardFlipped = false; // Reset flip state when changing cards
      notifyListeners();
    }
  }
  // ============================================================================
  // PUBLIC METHODS - Card Flip
  // ============================================================================

  /// Flip card hiện tại (toggle giữa mặt trước và mặt sau)
  /// Mặt trước: Hiển thị từ tiếng Việt
  /// Mặt sau: Hiển thị từ tiếng Anh, nghĩa, ví dụ, audio
  void flipCard() {
    _isCardFlipped = !_isCardFlipped;
    notifyListeners();
  }
  /// Flip specific card by index
  void flipCardAtIndex(int index) {
    _cardFlipStates[index] = !(_cardFlipStates[index] ?? false);
    notifyListeners();
  }

  /// Reset card flip state về ban đầu (hiển thị mặt trước)
  void resetCardFlip() {
    _isCardFlipped = false;    notifyListeners();
  }

  /// Clear tất cả vocabulary cards (sử dụng khi switch topics)
  /// Reset tất cả state về initial values
  void clearCards() {
    _currentTopicId = null;
    _vocabularyCards = [];
    _currentCardIndex = 0;
    _previousCardIndex = 0;
    _isCardFlipped = false;
    _cardFlipStates = {};
    _error = null;
    notifyListeners();
    _logInfo('Cleared vocabulary cards');
  }
  // ============================================================================
  // PUBLIC METHODS - Dots Indicator
  // ============================================================================

  /// Tính toán dot index cho UI indicator (hệ thống 4-dot với logic bất đối xứng)
  /// 
  /// **Logic:**
  /// - Nếu ≤ 4 cards: dot index = card index
  /// - Nếu > 4 cards: Sử dụng asymmetric logic dựa trên hướng swipe
  /// 
  /// **Asymmetric Rules:**
  /// - Card 0 → Dot 0 (luôn luôn)
  /// - Card 1 → Dot 1 (luôn luôn)
  /// - Card last → Dot 3 (luôn luôn)
  /// - Cards giữa: Dot 2 (forward) hoặc Dot 1 (backward)
  /// 
  /// **Trả về:** Index của dot cần highlight (0-3)
  int getDotIndex() {
    if (_vocabularyCards.length <= 4) {
      return _currentCardIndex;
    }

    // Logic bất đối xứng theo hướng lướt
    if (_currentCardIndex == 0) {
      return 0; // Dot 1
    } else if (_currentCardIndex == 1) {
      return 1; // Dot 2
    } else if (_currentCardIndex == _vocabularyCards.length - 1) {
      return 3; // Dot 4 (cuối)
    } else {
      // Cards 2,3,4,5 - Logic phụ thuộc hướng lướt
      if (_currentCardIndex == 2) {
        return isSwipingForward ? 2 : 1; // Dot 3 xuôi, Dot 2 ngược
      } else if (_currentCardIndex == 5 && _vocabularyCards.length > 6) {
        return 2; // Dot 3 cả xuôi và ngược
      } else {
        // Cards 3,4
        return isSwipingForward ? 2 : 1; // Dot 3 xuôi, Dot 2 ngược
      }
    }
  }

  // ============================================================================
  // PRIVATE HELPERS - State Management
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _resetNavigationState() {
    _currentCardIndex = 0;
    _previousCardIndex = 0;
    _isCardFlipped = false;
    _cardFlipStates = {};
  }

  // ============================================================================
  // PRIVATE HELPERS - Card Enrichment
  // ============================================================================

  /// Enrich multiple cards with dictionary data
  Future<List<VocabularyCard>> _enrichCards(List<VocabularyCard> cards) async {
    final enrichedCards = <VocabularyCard>[];

    for (var card in cards) {
      try {
        final enrichedCard = await enrichVocabularyCard.call(card);
        enrichedCards.add(enrichedCard);
        _logInfo('Enriched card: ${card.english}');
      } catch (e) {
        // If enrichment fails for a card, use original card
        enrichedCards.add(card);
        _logWarning('Could not enrich card ${card.english}: $e');
      }
    }

    return enrichedCards;
  }
  // ============================================================================
  // LOGGING HELPERS
  // ============================================================================

  void _logInfo(String message) {
    if (kDebugMode) {
      print('[VOCABULARY] $message');
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      print('[VOCABULARY] ⚠️ $message');
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      print('[VOCABULARY] ❌ $message');
    }
  }
}
