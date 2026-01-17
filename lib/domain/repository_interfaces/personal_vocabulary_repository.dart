// lib/domain/repository_interfaces/personal_vocabulary_repository.dart
// Repository interface cho Personal Vocabulary
// Giúp dễ dàng switch giữa Local Storage và Firebase

/// Abstract repository cho Personal Vocabulary
///
/// Thiết kế này cho phép:
/// - Hiện tại: dùng SharedPreferences (local)
/// - Tương lai: dùng Firestore (remote)
/// - Hoặc cả 2: sync local <-> remote
abstract class PersonalVocabularyRepository {
  /// Get all bookmarked card IDs for user
  Future<List<String>> getBookmarkedCardIds(String userId);

  /// Add card to personal vocabulary
  Future<void> addCard(String userId, String cardId);

  /// Remove card from personal vocabulary
  Future<void> removeCard(String userId, String cardId);

  /// Toggle bookmark status
  Future<bool> toggleBookmark(String userId, String cardId);

  /// Check if card is bookmarked
  Future<bool> isBookmarked(String userId, String cardId);

  /// Clear all bookmarks
  Future<void> clearAll(String userId);

  /// Get total count of bookmarked cards
  Future<int> getCardCount(String userId);

  /// Get statistics grouped by topic
  /// Returns Map<topicId, cardCount>
  Future<Map<String, int>> getStatsByTopic(String userId);

  /// Sync local data to remote (for future Firebase implementation)
  Future<void> syncToRemote(String userId);

  /// Sync remote data to local (for future Firebase implementation)
  Future<void> syncFromRemote(String userId);
}
