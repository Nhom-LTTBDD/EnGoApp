// lib/data/models/dictionary_model.dart

/// Model for Dictionary API response
/// API: https://api.dictionaryapi.dev/api/v2/entries/en/<word>
class DictionaryModel {
  final String word;
  final String? phonetic;
  final List<PhoneticModel> phonetics;
  final List<MeaningModel> meanings;

  const DictionaryModel({
    required this.word,
    this.phonetic,
    required this.phonetics,
    required this.meanings,
  });

  factory DictionaryModel.fromJson(Map<String, dynamic> json) {
    return DictionaryModel(
      word: json['word'] as String? ?? '',
      phonetic: json['phonetic'] as String?,
      phonetics: (json['phonetics'] as List<dynamic>?)
              ?.map((e) => PhoneticModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meanings: (json['meanings'] as List<dynamic>?)
              ?.map((e) => MeaningModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'phonetics': phonetics.map((e) => e.toJson()).toList(),
      'meanings': meanings.map((e) => e.toJson()).toList(),
    };
  }

  /// Get first audio URL if available
  String? get audioUrl {
    for (var phonetic in phonetics) {
      if (phonetic.audio != null && phonetic.audio!.isNotEmpty) {
        return phonetic.audio;
      }
    }
    return null;
  }

  /// Get all definitions from all meanings
  List<String> get allDefinitions {
    final definitions = <String>[];
    for (var meaning in meanings) {
      for (var definition in meaning.definitions) {
        definitions.add(definition.definition);
      }
    }
    return definitions;
  }

  /// Get first definition
  String? get firstDefinition {
    if (meanings.isEmpty || meanings.first.definitions.isEmpty) {
      return null;
    }
    return meanings.first.definitions.first.definition;
  }

  /// Get all part of speech
  List<String> get partsOfSpeech {
    return meanings.map((m) => m.partOfSpeech).toSet().toList();
  }
}

class PhoneticModel {
  final String? text;
  final String? audio;

  const PhoneticModel({
    this.text,
    this.audio,
  });

  factory PhoneticModel.fromJson(Map<String, dynamic> json) {
    return PhoneticModel(
      text: json['text'] as String?,
      audio: json['audio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'audio': audio,
    };
  }
}

class MeaningModel {
  final String partOfSpeech;
  final List<DefinitionModel> definitions;

  const MeaningModel({
    required this.partOfSpeech,
    required this.definitions,
  });

  factory MeaningModel.fromJson(Map<String, dynamic> json) {
    return MeaningModel(
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((e) => DefinitionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partOfSpeech': partOfSpeech,
      'definitions': definitions.map((e) => e.toJson()).toList(),
    };
  }
}

class DefinitionModel {
  final String definition;
  final String? example;

  const DefinitionModel({
    required this.definition,
    this.example,
  });

  factory DefinitionModel.fromJson(Map<String, dynamic> json) {
    return DefinitionModel(
      definition: json['definition'] as String? ?? '',
      example: json['example'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'example': example,
    };
  }
}
