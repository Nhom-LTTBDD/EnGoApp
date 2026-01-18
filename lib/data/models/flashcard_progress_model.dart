// lib/data/models/flashcard_progress_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/flashcard_progress.dart';

class FlashcardProgressModel extends FlashcardProgress {
  const FlashcardProgressModel({
    required super.id,
    required super.userId,
    required super.topicId,
    required super.masteredCardIds,
    required super.learningCardIds,
    required super.lastStudiedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Convert from Entity to Model
  factory FlashcardProgressModel.fromEntity(FlashcardProgress entity) {
    return FlashcardProgressModel(
      id: entity.id,
      userId: entity.userId,
      topicId: entity.topicId,
      masteredCardIds: entity.masteredCardIds,
      learningCardIds: entity.learningCardIds,
      lastStudiedAt: entity.lastStudiedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create from Firestore DocumentSnapshot
  factory FlashcardProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardProgressModel(
      id: doc.id,
      userId: data['userId'] as String,
      topicId: data['topicId'] as String,
      masteredCardIds: List<String>.from(data['masteredCardIds'] ?? []),
      learningCardIds: List<String>.from(data['learningCardIds'] ?? []),
      lastStudiedAt: (data['lastStudiedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'topicId': topicId,
      'masteredCardIds': masteredCardIds,
      'learningCardIds': learningCardIds,
      'lastStudiedAt': Timestamp.fromDate(lastStudiedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from JSON (for local storage)
  factory FlashcardProgressModel.fromJson(Map<String, dynamic> json) {
    return FlashcardProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      topicId: json['topicId'] as String,
      masteredCardIds: List<String>.from(json['masteredCardIds'] ?? []),
      learningCardIds: List<String>.from(json['learningCardIds'] ?? []),
      lastStudiedAt: DateTime.parse(json['lastStudiedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
