// lib/data/models/grammar_model.dart

/// # GrammarModels - Data Layer
/// 
/// **Purpose:** Models cho grammar data (lesson và topic) - Data Transfer Objects
/// **Architecture Layer:** Data
/// **Key Features:**
/// - fromJson / toJson cho serialization
/// - toEntity / fromEntity cho conversion Domain <-> Data
/// - Parse enums từ string (type, level, status)
/// 
/// **Models:**
/// - GrammarLessonModel: Model cho lesson
/// - GrammarTopicModel: Model cho topic

import '../../domain/entities/grammar_lesson.dart';
import '../../domain/entities/grammar_topic.dart';

/// Grammar lesson model for data layer
class GrammarLessonModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String level;
  final String status;
  final String? imageUrl;
  final int totalItems;
  final int completedItems;
  final int estimatedDurationMinutes;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  GrammarLessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.level,
    required this.status,
    this.imageUrl,
    this.totalItems = 0,
    this.completedItems = 0,
    this.estimatedDurationMinutes = 15,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  /// Deserialize từ JSON
  factory GrammarLessonModel.fromJson(Map<String, dynamic> json) {
    return GrammarLessonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'tenses',
      level: json['level'] ?? 'beginner',
      status: json['status'] ?? 'available',
      imageUrl: json['imageUrl'],
      totalItems: json['totalItems'] ?? 0,
      completedItems: json['completedItems'] ?? 0,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 15,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'level': level,
      'status': status,
      'imageUrl': imageUrl,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  /// Convert model sang domain entity
  GrammarLesson toEntity() {
    return GrammarLesson(
      id: id,
      title: title,
      description: description,
      type: _parseGrammarLessonType(type),
      level: _parseGrammarLevel(level),
      status: _parseGrammarLessonStatus(status),
      imageUrl: imageUrl,
      totalItems: totalItems,
      completedItems: completedItems,
      estimatedDuration: Duration(minutes: estimatedDurationMinutes),
      tags: tags,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
  /// Convert domain entity sang model
  factory GrammarLessonModel.fromEntity(GrammarLesson lesson) {
    return GrammarLessonModel(
      id: lesson.id,
      title: lesson.title,
      description: lesson.description,
      type: lesson.type.name,
      level: lesson.level.name,
      status: lesson.status.name,
      imageUrl: lesson.imageUrl,
      totalItems: lesson.totalItems,
      completedItems: lesson.completedItems,
      estimatedDurationMinutes: lesson.estimatedDuration.inMinutes,
      tags: lesson.tags,
      createdAt: lesson.createdAt.toIso8601String(),
      updatedAt: lesson.updatedAt.toIso8601String(),
    );
  }
  /// Helper methods để parse enums từ string
  GrammarLessonType _parseGrammarLessonType(String type) {
    return GrammarLessonType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => GrammarLessonType.tenses,
    );
  }

  GrammarLevel _parseGrammarLevel(String level) {
    return GrammarLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => GrammarLevel.beginner,
    );
  }

  GrammarLessonStatus _parseGrammarLessonStatus(String status) {
    return GrammarLessonStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => GrammarLessonStatus.available,
    );
  }
}

/// Grammar topic model for data layer
class GrammarTopicModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String level;
  final int totalLessons;
  final int completedLessons;
  final bool isUnlocked;
  final String createdAt;

  GrammarTopicModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.level,
    required this.totalLessons,
    this.completedLessons = 0,
    this.isUnlocked = true,
    required this.createdAt,
  });

  /// From JSON
  factory GrammarTopicModel.fromJson(Map<String, dynamic> json) {
    return GrammarTopicModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      level: json['level'] ?? 'beginner',
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? true,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
  /// Serialize sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'level': level,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'isUnlocked': isUnlocked,
      'createdAt': createdAt,
    };
  }

  /// Convert model sang domain entity (GrammarTopic)
  GrammarTopic toEntity() {
    return GrammarTopic(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      level: _parseGrammarLevel(level),
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      isUnlocked: isUnlocked,
      createdAt: DateTime.parse(createdAt),
    );
  }
  /// Convert domain entity sang model (GrammarTopicModel)
  factory GrammarTopicModel.fromEntity(GrammarTopic topic) {
    return GrammarTopicModel(
      id: topic.id,
      title: topic.title,
      description: topic.description,
      imageUrl: topic.imageUrl,
      level: topic.level.name,
      totalLessons: topic.totalLessons,
      completedLessons: topic.completedLessons,
      isUnlocked: topic.isUnlocked,
      createdAt: topic.createdAt.toIso8601String(),
    );
  }

  GrammarLevel _parseGrammarLevel(String level) {
    return GrammarLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => GrammarLevel.beginner,
    );
  }
}