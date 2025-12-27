// lib/presentation/providers/vocabulary_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/vocabulary_card.dart';
import '../../domain/usecase/get_vocabulary_cards.dart';

class VocabularyProvider extends ChangeNotifier {
  final GetVocabularyCards getVocabularyCards;

  VocabularyProvider({required this.getVocabularyCards});

  // State
  List<VocabularyCard> _vocabularyCards = [];
  bool _isLoading = false;
  String? _error;
  int _currentCardIndex = 0;
  int _previousCardIndex = 0;
  bool _isCardFlipped = false;

  // Getters
  List<VocabularyCard> get vocabularyCards => _vocabularyCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentCardIndex => _currentCardIndex;
  int get previousCardIndex => _previousCardIndex;
  bool get isCardFlipped => _isCardFlipped;

  // Computed properties
  VocabularyCard? get currentCard {
    if (_vocabularyCards.isEmpty ||
        _currentCardIndex >= _vocabularyCards.length) {
      return null;
    }
    return _vocabularyCards[_currentCardIndex];
  }

  bool get isSwipingForward => _currentCardIndex > _previousCardIndex;

  // Methods
  Future<void> loadVocabularyCards(String topicId) async {
    _setLoading(true);
    _setError(null);

    try {
      final cards = await getVocabularyCards.call(topicId);
      _vocabularyCards = cards;
      _currentCardIndex = 0;
      _previousCardIndex = 0;
      _isCardFlipped = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void setCurrentCardIndex(int index) {
    if (index >= 0 && index < _vocabularyCards.length) {
      _previousCardIndex = _currentCardIndex;
      _currentCardIndex = index;
      _isCardFlipped = false; // Reset flip state when changing cards
      notifyListeners();
    }
  }

  void flipCard() {
    _isCardFlipped = !_isCardFlipped;
    notifyListeners();
  }

  void resetCardFlip() {
    _isCardFlipped = false;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Dots logic for UI
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
}
