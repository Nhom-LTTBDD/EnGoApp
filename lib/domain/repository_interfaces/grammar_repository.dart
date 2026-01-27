// lib/domain/repository_interfaces/grammar_repository.dart

/// # GrammarRepository - Domain Interface
/// 
/// **Purpose:** Repository interface cho Grammar feature
/// **Architecture Layer:** Domain (Repository Interface)
/// **Design Pattern:** Repository Pattern
/// 
/// **Key Features:**
/// - CRUD cho topics và lessons
/// - Progress tracking (update progress, mark completed)
/// - Filter by level/type
/// - Search functionality
/// - Favorites management
/// - Recent lessons tracking
/// - AI recommendations (future)
/// 
/// **Implementation:** GrammarRepositoryImpl với mock data (chưa Firestore)

import '../entities/grammar_lesson.dart';
import '../entities/grammar_topic.dart';

/// Abstract grammar repository interface
abstract class GrammarRepository {
  /// Lấy tất cả grammar topics
  Future<List<GrammarTopic>> getGrammarTopics();

  /// Lấy grammar topic theo ID
  Future<GrammarTopic?> getGrammarTopicById(String topicId);

  /// Lấy lessons theo topic ID
  Future<List<GrammarLesson>> getLessonsByTopicId(String topicId);

  /// Lấy lesson theo ID
  Future<GrammarLesson?> getLessonById(String lessonId);

  /// Cập nhật progress của lesson (số items đã hoàn thành)
  Future<void> updateLessonProgress(String lessonId, int completedItems);

  /// Đánh dấu lesson đã hoàn thành
  Future<void> markLessonCompleted(String lessonId);

  /// Lấy lessons theo level (beginner/intermediate/advanced)
  Future<List<GrammarLesson>> getLessonsByLevel(GrammarLevel level);

  /// Lấy lessons theo type (tenses/verbs/nouns/etc)
  Future<List<GrammarLesson>> getLessonsByType(GrammarLessonType type);

  /// Search lessons theo query (title, description, tags)
  Future<List<GrammarLesson>> searchLessons(String query);

  /// Lấy danh sách lessons đã favorite
  Future<List<GrammarLesson>> getFavoriteLessons();

  /// Thêm lesson vào favorites
  Future<void> addToFavorites(String lessonId);

  /// Xóa lesson khỏi favorites
  Future<void> removeFromFavorites(String lessonId);

  /// Lấy recently accessed lessons
  Future<List<GrammarLesson>> getRecentLessons();

  /// Lấy recommended lessons dựa trên user progress (AI-based future)
  Future<List<GrammarLesson>> getRecommendedLessons();
}
