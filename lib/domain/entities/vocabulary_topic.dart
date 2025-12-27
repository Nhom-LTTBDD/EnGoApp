// lib/domain/entities/vocabulary_topic.dart

import 'vocabulary_card.dart';

class VocabularyTopic {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<VocabularyCard> cards;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;

  const VocabularyTopic({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.cards,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
  });

  int get cardCount => cards.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VocabularyTopic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VocabularyTopic(id: $id, name: $name, cardCount: $cardCount)';
  }
}
