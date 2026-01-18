// lib/presentation/providers/flashcard_provider.dart
import 'package:flutter/foundation.dart';

/// Provider quản lý state của flashcard page
class FlashcardProvider extends ChangeNotifier {
  // Score tracking
  int _correctCount = 0;
  int _wrongCount = 0;

  // Card state
  int _currentCardIndex = 0;
  bool _isFlipped = false;

  // Progress tracking - Track which cards are mastered
  final Set<String> _masteredCardIds = {};
  final Set<String> _learningCardIds = {};

  // Drag state
  double _dragOffset = 0.0;
  double _dragOffsetY = 0.0;
  bool _isDragging = false;
  bool _isCommittedToSwipe = false;

  // Getters
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  int get currentCardIndex => _currentCardIndex;
  bool get isFlipped => _isFlipped;
  double get dragOffset => _dragOffset;
  double get dragOffsetY => _dragOffsetY;
  bool get isDragging => _isDragging;
  bool get isCommittedToSwipe => _isCommittedToSwipe;
  Set<String> get masteredCardIds => Set.from(_masteredCardIds);
  Set<String> get learningCardIds => Set.from(_learningCardIds);

  // Progress methods
  void markCardAsMastered(String cardId) {
    _masteredCardIds.add(cardId);
    _learningCardIds.remove(cardId);
    notifyListeners();
  }

  void markCardAsLearning(String cardId) {
    _learningCardIds.add(cardId);
    _masteredCardIds.remove(cardId);
    notifyListeners();
  }

  void clearProgress() {
    _masteredCardIds.clear();
    _learningCardIds.clear();
    notifyListeners();
  }

  // Score methods
  void incrementCorrect() {
    _correctCount++;
    notifyListeners();
  }

  void incrementWrong() {
    _wrongCount++;
    notifyListeners();
  }

  void resetScores() {
    _correctCount = 0;
    _wrongCount = 0;
    notifyListeners();
  }

  // Card navigation
  void nextCard() {
    _currentCardIndex++;
    notifyListeners();
  }

  void resetToFirstCard() {
    _currentCardIndex = 0;
    _isFlipped = false;
    notifyListeners();
  }

  void setCurrentCardIndex(int index) {
    _currentCardIndex = index;
    notifyListeners();
  }

  // Flip methods
  void toggleFlip() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void resetFlip() {
    _isFlipped = false;
    notifyListeners();
  }

  // Drag methods
  void updateDragOffset(double dx, double dy) {
    _dragOffset += dx;
    _dragOffsetY += dy;
    notifyListeners();
  }

  void setDragging(bool value) {
    _isDragging = value;
    notifyListeners();
  }

  void setCommittedToSwipe(bool value) {
    _isCommittedToSwipe = value;
    notifyListeners();
  }

  void resetDrag() {
    _dragOffset = 0.0;
    _dragOffsetY = 0.0;
    _isDragging = false;
    _isCommittedToSwipe = false;
    notifyListeners();
  }

  // Complete reset
  void resetAll() {
    _correctCount = 0;
    _wrongCount = 0;
    _currentCardIndex = 0;
    _isFlipped = false;
    _dragOffset = 0.0;
    _dragOffsetY = 0.0;
    _isDragging = false;
    _isCommittedToSwipe = false;
    _masteredCardIds.clear();
    _learningCardIds.clear();
    notifyListeners();
  }
}
