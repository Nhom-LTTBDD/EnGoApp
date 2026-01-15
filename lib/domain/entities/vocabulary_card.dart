// lib/domain/entities/vocabulary_card.dart

class VocabularyCard {
  final String id;
  final String vietnamese;
  final String english;
  final String meaning;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Dictionary API enriched fields
  final String? phonetic;
  final List<String>? definitions;
  final List<String>? examples;
  final List<String>? partsOfSpeech;

  const VocabularyCard({
    required this.id,
    required this.vietnamese,
    required this.english,
    required this.meaning,
    this.imageUrl,
    this.audioUrl,
    required this.createdAt,
    required this.updatedAt,
    this.phonetic,
    this.definitions,
    this.examples,
    this.partsOfSpeech,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VocabularyCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VocabularyCard(id: $id, vietnamese: $vietnamese, english: $english)';
  }
}
