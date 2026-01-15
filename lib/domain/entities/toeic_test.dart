// lib/domain/entities/toeic_test.dart

class ToeicTest {
  final String id;
  final String name;
  final String description;
  final int totalQuestions;
  final int listeningQuestions;
  final int readingQuestions;
  final int duration; // in minutes
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int year;

  const ToeicTest({
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

  ToeicTest copyWith({
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
    return ToeicTest(
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

    return other is ToeicTest &&
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
    return 'ToeicTest(id: $id, name: $name, description: $description, totalQuestions: $totalQuestions, listeningQuestions: $listeningQuestions, readingQuestions: $readingQuestions, duration: $duration, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, year: $year)';
  }
}
