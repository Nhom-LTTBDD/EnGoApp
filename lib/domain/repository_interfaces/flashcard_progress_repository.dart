// lib/domain/repository_interfaces/flashcard_progress_repository.dart

import '../entities/flashcard_progress.dart';

abstract class FlashcardProgressRepository {
  /// Get progress for a specific topic and user
  Future<FlashcardProgress?> getProgress({
    required String userId,
    required String topicId,
  });

  /// Save or update progress
  Future<void> saveProgress(FlashcardProgress progress);

  /// Update mastered and learning card lists
  Future<void> updateCardProgress({
    required String userId,
    required String topicId,
    required List<String> masteredCardIds,
    required List<String> learningCardIds,
  });

  /// Reset progress for a topic (clear all progress)
  Future<void> resetProgress({required String userId, required String topicId});

  /// Sync local data to Firestore (for background sync)
  Future<void> syncToFirestore();

  /// Check if local data exists
  Future<bool> hasLocalData({required String userId, required String topicId});
}
