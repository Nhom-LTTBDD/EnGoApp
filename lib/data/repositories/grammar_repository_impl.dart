// lib/data/repositories/grammar_repository_impl.dart
// Grammar repository implementation với mock data

import '../../domain/entities/grammar_lesson.dart';
import '../../domain/entities/grammar_topic.dart';
import '../../domain/repository_interfaces/grammar_repository.dart';
import '../models/grammar_model.dart';

/// Grammar repository implementation with mock data
class GrammarRepositoryImpl implements GrammarRepository {
  
  @override
  Future<List<GrammarTopic>> getGrammarTopics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockTopicsData = [
      {
        'id': '1',
        'title': 'Các thì trong tiếng Anh',
        'description': 'Học các thì cơ bản và nâng cao trong tiếng Anh',
        'level': 'beginner',
        'totalLessons': 12,
        'completedLessons': 3,
        'isUnlocked': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': '2',
        'title': 'Các dạng thức của động từ',
        'description': 'Tìm hiểu về các dạng thức và cách sử dụng động từ',
        'level': 'intermediate',
        'totalLessons': 8,
        'completedLessons': 1,
        'isUnlocked': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      },
      {
        'id': '3',
        'title': 'Động từ khiếm khuyết',
        'description': 'Học cách sử dụng các động từ khiếm khuyết',
        'level': 'intermediate',
        'totalLessons': 6,
        'completedLessons': 0,
        'isUnlocked': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      },
      {
        'id': '4',
        'title': 'Các loại từ',
        'description': 'Phân biệt và sử dụng các loại từ trong câu',
        'level': 'beginner',
        'totalLessons': 10,
        'completedLessons': 0,
        'isUnlocked': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'id': '5',
        'title': 'So sánh trong tiếng Anh',
        'description': 'Học các cấp độ so sánh của tính từ và trạng từ',
        'level': 'intermediate',
        'totalLessons': 5,
        'completedLessons': 0,
        'isUnlocked': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];
    
    return mockTopicsData
        .map((data) => GrammarTopicModel.fromJson(data).toEntity())
        .toList();
  }

  @override
  Future<List<GrammarLesson>> getLessonsByTopicId(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final Map<String, List<Map<String, dynamic>>> mockLessonsData = {
      '1': [
        {
          'id': '1-1',
          'title': 'Thì hiện tại đơn',
          'description': 'Học cách sử dụng thì hiện tại đơn trong tiếng Anh',
          'type': 'tenses',
          'level': 'beginner',
          'status': 'completed',
          'totalItems': 10,
          'completedItems': 10,
          'estimatedDurationMinutes': 15,
          'tags': ['present', 'simple', 'basic'],
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'updatedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': '1-2',
          'title': 'Thì quá khứ đơn',
          'description': 'Tìm hiểu về thì quá khứ đơn và cách sử dụng',
          'type': 'tenses',
          'level': 'beginner',
          'status': 'inProgress',
          'totalItems': 12,
          'completedItems': 7,
          'estimatedDurationMinutes': 20,
          'tags': ['past', 'simple', 'basic'],
          'createdAt': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': '1-3',
          'title': 'Thì tương lai đơn',
          'description': 'Học cách diễn tả tương lai trong tiếng Anh',
          'type': 'tenses',
          'level': 'beginner',
          'status': 'available',
          'totalItems': 10,
          'completedItems': 0,
          'estimatedDurationMinutes': 18,
          'tags': ['future', 'simple', 'will'],
          'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'updatedAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
      ],
      '2': [
        {
          'id': '2-1',
          'title': 'Động từ to-be',
          'description': 'Cách sử dụng động từ to-be trong các thì khác nhau',
          'type': 'verbs',
          'level': 'beginner',
          'status': 'available',
          'totalItems': 8,
          'completedItems': 0,
          'estimatedDurationMinutes': 12,
          'tags': ['be', 'verb', 'basic'],
          'createdAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'updatedAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        },
      ],
    };
    
    final lessonsData = mockLessonsData[topicId] ?? [];
    return lessonsData
        .map((data) => GrammarLessonModel.fromJson(data).toEntity())
        .toList();
  }

  @override
  Future<GrammarTopic?> getGrammarTopicById(String topicId) async {
    final topics = await getGrammarTopics();
    try {
      return topics.firstWhere((topic) => topic.id == topicId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<GrammarLesson?> getLessonById(String lessonId) async {
    // Get all lessons from all topics and find by ID
    final topics = await getGrammarTopics();
    for (final topic in topics) {
      final lessons = await getLessonsByTopicId(topic.id);
      try {
        return lessons.firstWhere((lesson) => lesson.id == lessonId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  @override
  Future<void> updateLessonProgress(String lessonId, int completedItems) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In real implementation, this would update the backend
    print('Updated lesson $lessonId progress: $completedItems');
  }

  @override
  Future<void> markLessonCompleted(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In real implementation, this would mark lesson as completed
    print('Marked lesson $lessonId as completed');
  }

  @override
  Future<List<GrammarLesson>> getLessonsByLevel(GrammarLevel level) async {
    final topics = await getGrammarTopics();
    final List<GrammarLesson> allLessons = [];
    
    for (final topic in topics) {
      final lessons = await getLessonsByTopicId(topic.id);
      allLessons.addAll(lessons.where((lesson) => lesson.level == level));
    }
    
    return allLessons;
  }

  @override
  Future<List<GrammarLesson>> getLessonsByType(GrammarLessonType type) async {
    final topics = await getGrammarTopics();
    final List<GrammarLesson> allLessons = [];
    
    for (final topic in topics) {
      final lessons = await getLessonsByTopicId(topic.id);
      allLessons.addAll(lessons.where((lesson) => lesson.type == type));
    }
    
    return allLessons;
  }

  @override
  Future<List<GrammarLesson>> searchLessons(String query) async {
    final topics = await getGrammarTopics();
    final List<GrammarLesson> allLessons = [];
    
    for (final topic in topics) {
      final lessons = await getLessonsByTopicId(topic.id);
      allLessons.addAll(
        lessons.where(
          (lesson) =>
              lesson.title.toLowerCase().contains(query.toLowerCase()) ||
              lesson.description.toLowerCase().contains(query.toLowerCase()) ||
              lesson.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              ),
        ),
      );
    }
    
    return allLessons;
  }

  @override
  Future<List<GrammarLesson>> getFavoriteLessons() async {
    // Mock favorite lessons
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  @override
  Future<void> addToFavorites(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Added lesson $lessonId to favorites');
  }

  @override
  Future<void> removeFromFavorites(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Removed lesson $lessonId from favorites');
  }

  @override
  Future<List<GrammarLesson>> getRecentLessons() async {
    // Mock recent lessons
    await Future.delayed(const Duration(milliseconds: 200));
    final lessons = await getLessonsByTopicId('1');
    return lessons.take(3).toList();
  }

  @override
  Future<List<GrammarLesson>> getRecommendedLessons() async {
    // Mock recommended lessons based on user progress
    await Future.delayed(const Duration(milliseconds: 200));
    final lessons = await getLessonsByLevel(GrammarLevel.beginner);
    return lessons.where((lesson) => lesson.isAvailable).take(5).toList();
  }
}