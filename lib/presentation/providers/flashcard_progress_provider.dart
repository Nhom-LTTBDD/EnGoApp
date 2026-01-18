// lib/presentation/providers/flashcard_progress_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/flashcard_progress.dart';
import '../../domain/usecases/flashcard/get_flashcard_progress.dart';
import '../../domain/usecases/flashcard/save_flashcard_progress.dart';
import '../../domain/usecases/flashcard/update_card_progress.dart';
import '../../domain/usecases/flashcard/reset_flashcard_progress.dart';

enum ProgressStatus { initial, loading, loaded, error }

class FlashcardProgressProvider with ChangeNotifier {
  final GetFlashcardProgress _getProgress;
  final SaveFlashcardProgress _saveProgress;
  final UpdateCardProgress _updateProgress;
  final ResetFlashcardProgress _resetProgress;

  // Current user ID
  String _userId = 'default_user';

  FlashcardProgressProvider({
    required GetFlashcardProgress getProgress,
    required SaveFlashcardProgress saveProgress,
    required UpdateCardProgress updateProgress,
    required ResetFlashcardProgress resetProgress,
  }) : _getProgress = getProgress,
       _saveProgress = saveProgress,
       _updateProgress = updateProgress,
       _resetProgress = resetProgress;

  // State
  FlashcardProgress? _currentProgress;
  ProgressStatus _status = ProgressStatus.initial;
  String? _errorMessage;

  // Getters
  FlashcardProgress? get currentProgress => _currentProgress;
  ProgressStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProgressStatus.loading;
  bool get hasProgress => _currentProgress != null;
  String get userId => _userId;

  /// Set user ID
  void setUserId(String userId) {
    if (_userId != userId) {
      print('🔄 FlashcardProgressProvider: Switching user to $userId');
      _userId = userId;
      // Clear old progress when switching users
      clearProgress();
    }
  }

  /// Load progress for a specific topic
  Future<void> loadProgress({
    required String userId,
    required String topicId,
  }) async {
    _status = ProgressStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentProgress = await _getProgress(userId: userId, topicId: topicId);
      _status = ProgressStatus.loaded;
    } catch (e) {
      _status = ProgressStatus.error;
      _errorMessage = e.toString();
      print('Error loading progress: $e');
    }
    notifyListeners();
  }

  /// Save progress
  Future<void> saveProgress(FlashcardProgress progress) async {
    try {
      await _saveProgress(progress);
      _currentProgress = progress;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error saving progress: $e');
    }
  }

  /// Update card progress after study session
  Future<void> updateCards({
    required String userId,
    required String topicId,
    required List<String> masteredCardIds,
    required List<String> learningCardIds,
  }) async {
    try {
      await _updateProgress(
        userId: userId,
        topicId: topicId,
        masteredCardIds: masteredCardIds,
        learningCardIds: learningCardIds,
      );

      // Reload to get updated progress
      await loadProgress(userId: userId, topicId: topicId);
    } catch (e) {
      _errorMessage = e.toString();
      print('Error updating cards: $e');
    }
  }

  /// Reset progress (start over)
  Future<void> resetProgress({
    required String userId,
    required String topicId,
  }) async {
    try {
      await _resetProgress(userId: userId, topicId: topicId);

      // Reload to get reset progress
      await loadProgress(userId: userId, topicId: topicId);
    } catch (e) {
      _errorMessage = e.toString();
      print('Error resetting progress: $e');
    }
  }

  /// Clear current progress (for navigation away)
  void clearProgress() {
    _currentProgress = null;
    _status = ProgressStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  /// Get cards to study (only learning cards)
  List<String> getCardsToStudy() {
    return _currentProgress?.learningCardIds ?? [];
  }

  /// Check if a card is mastered
  bool isCardMastered(String cardId) {
    return _currentProgress?.masteredCardIds.contains(cardId) ?? false;
  }

  /// Get progress percentage
  double getProgressPercentage() {
    return _currentProgress?.masteryPercentage ?? 0.0;
  }

  /// Check if topic is completed
  bool isTopicCompleted() {
    return _currentProgress?.isCompleted ?? false;
  }
}
