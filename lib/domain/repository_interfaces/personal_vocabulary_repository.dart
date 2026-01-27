// lib/domain/repository_interfaces/personal_vocabulary_repository.dart

/// # PersonalVocabularyRepository - Domain Interface
/// 
/// **Purpose:** Repository interface cho Personal Vocabulary feature
/// **Architecture Layer:** Domain (Repository Interface)
/// **Design Pattern:** Repository Pattern - Abstraction over data sources
/// 
/// **Key Features:**
/// - CRUD operations cho bookmarked cards
/// - Toggle bookmark
/// - Statistics và count
/// - Future-ready sync methods cho Firebase
/// 
/// **Implementation Strategy:**
/// - Current: SharedPreferences (local storage)
/// - Future: Firestore (remote storage)
/// - Hybrid: Local cache + remote sync

abstract class PersonalVocabularyRepository {
  /// Lấy tất cả card IDs đã bookmark của user
  Future<List<String>> getBookmarkedCardIds(String userId);

  /// Thêm card vào personal vocabulary
  Future<void> addCard(String userId, String cardId);

  /// Xóa card khỏi personal vocabulary
  Future<void> removeCard(String userId, String cardId);

  /// Toggle bookmark status (add nếu chưa có, remove nếu đã có)
  /// Returns: true nếu đã add, false nếu đã remove
  Future<bool> toggleBookmark(String userId, String cardId);

  /// Kiểm tra card đã được bookmark chưa
  Future<bool> isBookmarked(String userId, String cardId);

  /// Xóa tất cả bookmarks của user
  Future<void> clearAll(String userId);

  /// Lấy tổng số cards đã bookmark
  Future<int> getCardCount(String userId);

  /// Lấy statistics grouped by topic
  /// Returns: Map<topicId, cardCount>
  Future<Map<String, int>> getStatsByTopic(String userId);

  /// Sync local data lên remote (cho future Firebase implementation)
  Future<void> syncToRemote(String userId);

  /// Sync remote data xuống local (cho future Firebase implementation)
  Future<void> syncFromRemote(String userId);
}
