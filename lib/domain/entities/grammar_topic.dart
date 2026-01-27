// lib/domain/entities/grammar_topic.dart

/// # GrammarTopic - Domain Entity
/// 
/// **Purpose:** Entity đại diện cho một grammar topic (chủ đề ngữ pháp)
/// **Architecture Layer:** Domain (Business Logic)
/// **Key Features:**
/// - Chứa danh sách lessons
/// - Progress tracking (totalLessons, completedLessons)
/// - Level classification (beginner/intermediate/advanced)
/// - Unlock status
/// 
/// **Computed Properties:**
/// - progressPercentage: Tính % hoàn thành topic
/// - isCompleted: Check topic đã hoàn thành
/// - availableLessons: Filter lessons available
/// - completedLessonsData: Filter lessons completed

import 'package:equatable/equatable.dart';
import 'grammar_lesson.dart';

/// Grammar topic entity
class GrammarTopic extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final GrammarLevel level;
  final List<GrammarLesson> lessons;
  final int totalLessons;
  final int completedLessons;
  final bool isUnlocked;
  final DateTime createdAt;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.level,
    this.lessons = const [],
    required this.totalLessons,
    this.completedLessons = 0,
    this.isUnlocked = true,
    required this.createdAt,
  });
  /// Tính phần trăm hoàn thành topic (0.0 - 1.0)
  double get progressPercentage {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons).clamp(0.0, 1.0);
  }
  /// Kiểm tra topic đã hoàn thành chưa
  bool get isCompleted => completedLessons >= totalLessons;

  /// Lấy danh sách lessons có thể học (status = available)
  List<GrammarLesson> get availableLessons {
    return lessons.where((lesson) => lesson.isAvailable).toList();
  }

  /// Lấy danh sách lessons đã hoàn thành  
  List<GrammarLesson> get completedLessonsData {
    return lessons.where((lesson) => lesson.isCompleted).toList();
  }

  /// Copy with new values để update immutable object
  GrammarTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    GrammarLevel? level,
    List<GrammarLesson>? lessons,
    int? totalLessons,
    int? completedLessons,
    bool? isUnlocked,
    DateTime? createdAt,
  }) {
    return GrammarTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      level: level ?? this.level,
      lessons: lessons ?? this.lessons,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        level,
        lessons,
        totalLessons,
        completedLessons,
        isUnlocked,
        createdAt,
      ];
}
