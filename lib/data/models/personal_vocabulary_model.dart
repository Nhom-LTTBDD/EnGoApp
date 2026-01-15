// lib/data/models/personal_vocabulary_model.dart

import '../../domain/entities/vocabulary_card.dart';

/// Model cho từ vựng cá nhân của người dùng
class PersonalVocabularyModel {
  final String id;
  final String userId;
  final List<String> vocabularyCardIds; // List of card IDs đã bookmark
  final DateTime createdAt;
  final DateTime updatedAt;

  const PersonalVocabularyModel({
    required this.id,
    required this.userId,
    required this.vocabularyCardIds,
    required this.createdAt,
    required this.updatedAt,
  });

  // Copy with method
  PersonalVocabularyModel copyWith({
    String? id,
    String? userId,
    List<String>? vocabularyCardIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalVocabularyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vocabularyCardIds: vocabularyCardIds ?? this.vocabularyCardIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if card is bookmarked
  bool isBookmarked(String cardId) {
    return vocabularyCardIds.contains(cardId);
  }

  // Add card to bookmarks
  PersonalVocabularyModel addCard(String cardId) {
    if (vocabularyCardIds.contains(cardId)) {
      return this;
    }
    return copyWith(
      vocabularyCardIds: [...vocabularyCardIds, cardId],
      updatedAt: DateTime.now(),
    );
  }

  // Remove card from bookmarks
  PersonalVocabularyModel removeCard(String cardId) {
    return copyWith(
      vocabularyCardIds: vocabularyCardIds.where((id) => id != cardId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Toggle bookmark
  PersonalVocabularyModel toggleBookmark(String cardId) {
    if (vocabularyCardIds.contains(cardId)) {
      return removeCard(cardId);
    } else {
      return addCard(cardId);
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vocabularyCardIds': vocabularyCardIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory PersonalVocabularyModel.fromJson(Map<String, dynamic> json) {
    return PersonalVocabularyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vocabularyCardIds: List<String>.from(json['vocabularyCardIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Empty model
  factory PersonalVocabularyModel.empty(String userId) {
    final now = DateTime.now();
    return PersonalVocabularyModel(
      id: 'personal_$userId',
      userId: userId,
      vocabularyCardIds: [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
