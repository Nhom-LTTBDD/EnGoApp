// lib/domain/entities/grammar_lesson.dart

/// # GrammarLesson - Domain Entity
/// 
/// **Purpose:** Entity đại diện cho một grammar lesson (bài học ngữ pháp)
/// **Architecture Layer:** Domain (Business Logic)
/// **Key Features:**
/// - Progress tracking (totalItems, completedItems)
/// - Status: locked, available, completed, inProgress
/// - Level: beginner, intermediate, advanced
/// - Type: tenses, verbs, nouns, adjectives, sentences, clauses
/// - Estimated duration và tags
/// 
/// **Computed Properties:**
/// - completionPercentage: Tính % hoàn thành
/// - isCompleted, isLocked, isAvailable: Status checks

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
  /// Tính phần trăm hoàn thành (0.0 - 1.0)
  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return (completedItems / totalItems).clamp(0.0, 1.0);
  }
  /// Kiểm tra lesson đã hoàn thành chưa
  bool get isCompleted => status == GrammarLessonStatus.completed;

  /// Kiểm tra lesson có bị lock không
  bool get isLocked => status == GrammarLessonStatus.locked;

  /// Kiểm tra lesson có available để học không
  bool get isAvailable => status == GrammarLessonStatus.available;

  /// Copy with new values để update immutable object
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
