// lib/data/models/vocabulary_card_model.dart

import '../../domain/entities/vocabulary_card.dart';

class VocabularyCardModel extends VocabularyCard {
  const VocabularyCardModel({
    required super.id,
    required super.vietnamese,
    required super.english,
    required super.meaning,
    super.imageUrl,
    super.audioUrl,
    required super.createdAt,
    required super.updatedAt,
    super.phonetic,
    super.definitions,
    super.examples,
    super.partsOfSpeech,
  });

  factory VocabularyCardModel.fromJson(Map<String, dynamic> json) {
    return VocabularyCardModel(
      id: json['id'] as String,
      vietnamese: json['vietnamese'] as String,
      english: json['english'] as String,
      meaning: json['meaning'] as String,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      phonetic: json['phonetic'] as String?,
      definitions: (json['definitions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      partsOfSpeech: (json['partsOfSpeech'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vietnamese': vietnamese,
      'english': english,
      'meaning': meaning,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'phonetic': phonetic,
      'definitions': definitions,
      'examples': examples,
      'partsOfSpeech': partsOfSpeech,
    };
  }

  factory VocabularyCardModel.fromEntity(VocabularyCard entity) {
    return VocabularyCardModel(
      id: entity.id,
      vietnamese: entity.vietnamese,
      english: entity.english,
      meaning: entity.meaning,
      imageUrl: entity.imageUrl,
      audioUrl: entity.audioUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      phonetic: entity.phonetic,
      definitions: entity.definitions,
      examples: entity.examples,
      partsOfSpeech: entity.partsOfSpeech,
    );
  }
}
