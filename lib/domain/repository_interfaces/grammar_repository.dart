// lib/domain/repository_interfaces/grammar_repository.dart
// Grammar repository interface cho abstraction layer

import '../entities/grammar_lesson.dart';
import '../entities/grammar_topic.dart';

/// Abstract grammar repository interface
abstract class GrammarRepository {
  /// Get all grammar topics
  Future<List<GrammarTopic>> getGrammarTopics();

  /// Get grammar topic by ID
  Future<GrammarTopic?> getGrammarTopicById(String topicId);

  /// Get lessons by topic ID
  Future<List<GrammarLesson>> getLessonsByTopicId(String topicId);

  /// Get lesson by ID
  Future<GrammarLesson?> getLessonById(String lessonId);

  /// Update lesson progress
  Future<void> updateLessonProgress(String lessonId, int completedItems);

  /// Mark lesson as completed
  Future<void> markLessonCompleted(String lessonId);

  /// Get lessons by level
  Future<List<GrammarLesson>> getLessonsByLevel(GrammarLevel level);

  /// Get lessons by type
  Future<List<GrammarLesson>> getLessonsByType(GrammarLessonType type);

  /// Search lessons by query
  Future<List<GrammarLesson>> searchLessons(String query);

  /// Get user's favorite lessons
  Future<List<GrammarLesson>> getFavoriteLessons();

  /// Add lesson to favorites
  Future<void> addToFavorites(String lessonId);

  /// Remove lesson from favorites
  Future<void> removeFromFavorites(String lessonId);

  /// Get recently accessed lessons
  Future<List<GrammarLesson>> getRecentLessons();

  /// Get recommended lessons based on user progress
  Future<List<GrammarLesson>> getRecommendedLessons();
}
