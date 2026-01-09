// lib/domain/entities/grammar_lesson.dart
// Grammar lesson entity cho business logic

import 'package:equatable/equatable.dart';

/// Grammar lesson levels
enum GrammarLevel { beginner, intermediate, advanced }

/// Grammar lesson types  
enum GrammarLessonType { tenses, verbs, nouns, adjectives, sentences, clauses }

/// Grammar lesson status
enum GrammarLessonStatus { locked, available, completed, inProgress }

/// Grammar lesson entity
class GrammarLesson extends Equatable {
  final String id;
  final String title;
  final String description;
  final GrammarLessonType type;
  final GrammarLevel level;
  final GrammarLessonStatus status;
  final String? imageUrl;
  final int totalItems;
  final int completedItems;
  final Duration estimatedDuration;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GrammarLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.level,
    required this.status,
    this.imageUrl,
    this.totalItems = 0,
    this.completedItems = 0,
    this.estimatedDuration = const Duration(minutes: 15),
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return (completedItems / totalItems).clamp(0.0, 1.0);
  }

  /// Check if lesson is completed
  bool get isCompleted => status == GrammarLessonStatus.completed;

  /// Check if lesson is locked
  bool get isLocked => status == GrammarLessonStatus.locked;

  /// Check if lesson is available
  bool get isAvailable => status == GrammarLessonStatus.available;

  /// Copy with new values
  GrammarLesson copyWith({
    String? id,
    String? title,
    String? description,
    GrammarLessonType? type,
    GrammarLevel? level,
    GrammarLessonStatus? status,
    String? imageUrl,
    int? totalItems,
    int? completedItems,
    Duration? estimatedDuration,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GrammarLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      level: level ?? this.level,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        level,
        status,
        imageUrl,
        totalItems,
        completedItems,
        estimatedDuration,
        tags,
        createdAt,
        updatedAt,
      ];
}
