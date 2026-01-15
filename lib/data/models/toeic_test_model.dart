// lib/data/models/toeic_test_model.dart

import '../../domain/entities/toeic_test.dart';

class ToeicTestModel {
  final String id;
  final String name;
  final String description;
  final int totalQuestions;
  final int listeningQuestions;
  final int readingQuestions;
  final int duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int year;

  const ToeicTestModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalQuestions,
    required this.listeningQuestions,
    required this.readingQuestions,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.year,
  });

  factory ToeicTestModel.fromJson(Map<String, dynamic> json) {
    return ToeicTestModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      listeningQuestions: json['listeningQuestions'] as int? ?? 0,
      readingQuestions: json['readingQuestions'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      year: json['year'] as int? ?? DateTime.now().year,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalQuestions': totalQuestions,
      'listeningQuestions': listeningQuestions,
      'readingQuestions': readingQuestions,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'year': year,
    };
  }

  factory ToeicTestModel.fromEntity(ToeicTest entity) {
    return ToeicTestModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      totalQuestions: entity.totalQuestions,
      listeningQuestions: entity.listeningQuestions,
      readingQuestions: entity.readingQuestions,
      duration: entity.duration,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      year: entity.year,
    );
  }

  ToeicTest toEntity() {
    return ToeicTest(
      id: id,
      name: name,
      description: description,
      totalQuestions: totalQuestions,
      listeningQuestions: listeningQuestions,
      readingQuestions: readingQuestions,
      duration: duration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      year: year,
    );
  }

  ToeicTestModel copyWith({
    String? id,
    String? name,
    String? description,
    int? totalQuestions,
    int? listeningQuestions,
    int? readingQuestions,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? year,
  }) {
    return ToeicTestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      listeningQuestions: listeningQuestions ?? this.listeningQuestions,
      readingQuestions: readingQuestions ?? this.readingQuestions,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      year: year ?? this.year,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ToeicTestModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.totalQuestions == totalQuestions &&
        other.listeningQuestions == listeningQuestions &&
        other.readingQuestions == readingQuestions &&
        other.duration == duration &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.year == year;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        totalQuestions.hashCode ^
        listeningQuestions.hashCode ^
        readingQuestions.hashCode ^
        duration.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode ^
        year.hashCode;
  }

  @override
  String toString() {
    return 'ToeicTestModel(id: $id, name: $name, description: $description, totalQuestions: $totalQuestions, listeningQuestions: $listeningQuestions, readingQuestions: $readingQuestions, duration: $duration, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, year: $year)';
  }
}
