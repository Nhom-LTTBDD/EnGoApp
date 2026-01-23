// lib/presentation/providers/flashcard_provider.dart
import 'package:flutter/foundation.dart';

/// History item để lưu trạng thái của mỗi action
class _ActionHistory {
  final String cardId;
  final bool wasMastered; // true nếu card được đánh dấu mastered
  final int previousIndex;

  _ActionHistory({
    required this.cardId,
    required this.wasMastered,
    required this.previousIndex,
  });
}

/// Provider quản lý state của flashcard page
class FlashcardProvider extends ChangeNotifier {
  // Score tracking
  int _knownCount = 0;
  int _unknownCount = 0;

  // Card state
  int _currentCardIndex = 0;
  bool _isFlipped = false;

  // Progress tracking - Track which cards are mastered
  final Set<String> _masteredCardIds = {};
  final Set<String> _learningCardIds = {};

  // History tracking cho undo
  final List<_ActionHistory> _history = [];

  // Drag state
  double _dragOffset = 0.0;
  double _dragOffsetY = 0.0;
  bool _isDragging = false;
  bool _isCommittedToSwipe = false;

  // Getters
  int get knownCount => _knownCount;
  int get unknownCount => _unknownCount;
  int get currentCardIndex => _currentCardIndex;
  bool get isFlipped => _isFlipped;
  double get dragOffset => _dragOffset;
  double get dragOffsetY => _dragOffsetY;
  bool get isDragging => _isDragging;
  bool get isCommittedToSwipe => _isCommittedToSwipe;
  Set<String> get masteredCardIds => Set.from(_masteredCardIds);
  Set<String> get learningCardIds => Set.from(_learningCardIds);
  bool get canUndo => _history.isNotEmpty;

  // Progress methods
  void markCardAsMastered(String cardId) {
    // Lưu vào history trước khi thay đổi
    _history.add(
      _ActionHistory(
        cardId: cardId,
        wasMastered: true,
        previousIndex: _currentCardIndex,
      ),
    );

    _masteredCardIds.add(cardId);
    _learningCardIds.remove(cardId);
    notifyListeners();
  }

  void markCardAsLearning(String cardId) {
    // Lưu vào history trước khi thay đổi
    _history.add(
      _ActionHistory(
        cardId: cardId,
        wasMastered: false,
        previousIndex: _currentCardIndex,
      ),
    );

    _learningCardIds.add(cardId);
    _masteredCardIds.remove(cardId);
    notifyListeners();
  }

  /// Undo action cuối cùng - quay lại thẻ trước
  bool undoLastAction() {
    if (_history.isEmpty) return false;

    final lastAction = _history.removeLast();

    // Quay lại index trước đó
    _currentCardIndex = lastAction.previousIndex;

    // Thu hồi trạng thái
    if (lastAction.wasMastered) {
      _masteredCardIds.remove(lastAction.cardId);
      _knownCount = (_knownCount - 1).clamp(0, 999);
    } else {
      _learningCardIds.remove(lastAction.cardId);
      _unknownCount = (_unknownCount - 1).clamp(0, 999);
    }

    // Reset flip và drag state
    _isFlipped = false;
    _dragOffset = 0.0;
    _dragOffsetY = 0.0;
    _isDragging = false;
    _isCommittedToSwipe = false;

    notifyListeners();
    return true;
  }

  void clearProgress() {
    _masteredCardIds.clear();
    _learningCardIds.clear();
    _history.clear(); // Xóa luôn history
    notifyListeners();
  }

  // Score methods
  void incrementCorrect() {
    _knownCount++;
    notifyListeners();
  }

  void incrementWrong() {
    _unknownCount++;
    notifyListeners();
  }

  void resetScores() {
    _knownCount = 0;
    _unknownCount = 0;
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
    _knownCount = 0;
    _unknownCount = 0;
    _currentCardIndex = 0;
    _isFlipped = false;
    _dragOffset = 0.0;
    _dragOffsetY = 0.0;
    _isDragging = false;
    _isCommittedToSwipe = false;
    _masteredCardIds.clear();
    _learningCardIds.clear();
    _history.clear(); // Xóa luôn history khi reset
    notifyListeners();
  }
}
