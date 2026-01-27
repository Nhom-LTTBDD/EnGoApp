// lib/domain/entities/grammar_topic.dart

/// # GrammarTopic - Domain Entity
/// 
/// **Purpose:** Entity đại diện cho một grammar topic (chủ đề ngữ pháp)
/// **Architecture Layer:** Domain (Business Logic)
/// **Key Features:**
/// - Chứa danh sách lessons (chỉ xem lý thuyết)
/// - Level classification (beginner/intermediate/advanced)
/// - Unlock status
/// 
/// **Note:** Không có progress tracking vì chỉ dùng để xem lý thuyết

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
    this.completedLessons = 0,    this.isUnlocked = true,
    required this.createdAt,
  });

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
