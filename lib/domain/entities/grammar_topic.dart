// lib/domain/entities/grammar_topic.dart
// Grammar topic entity cho business logic

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

  /// Calculate topic progress percentage
  double get progressPercentage {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons).clamp(0.0, 1.0);
  }

  /// Check if topic is completed
  bool get isCompleted => completedLessons >= totalLessons;

  /// Get available lessons
  List<GrammarLesson> get availableLessons {
    return lessons.where((lesson) => lesson.isAvailable).toList();
  }

  /// Get completed lessons  
  List<GrammarLesson> get completedLessonsData {
    return lessons.where((lesson) => lesson.isCompleted).toList();
  }

  /// Copy with new values
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
