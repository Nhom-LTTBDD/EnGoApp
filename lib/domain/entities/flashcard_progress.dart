// lib/domain/entities/flashcard_progress.dart

class FlashcardProgress {
  final String id; // userId_topicId
  final String userId;
  final String topicId;
  final List<String> masteredCardIds; // Danh sách ID các thẻ đã biết
  final List<String> learningCardIds; // Danh sách ID các thẻ đang học
  final DateTime lastStudiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FlashcardProgress({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.masteredCardIds,
    required this.learningCardIds,
    required this.lastStudiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if all cards are mastered
  bool get isCompleted => learningCardIds.isEmpty;

  /// Get total cards count
  int get totalCards => masteredCardIds.length + learningCardIds.length;

  /// Get mastery percentage
  double get masteryPercentage {
    if (totalCards == 0) return 0.0;
    return (masteredCardIds.length / totalCards) * 100;
  }

  /// Copy with method
  FlashcardProgress copyWith({
    String? id,
    String? userId,
    String? topicId,
    List<String>? masteredCardIds,
    List<String>? learningCardIds,
    DateTime? lastStudiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FlashcardProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      masteredCardIds: masteredCardIds ?? this.masteredCardIds,
      learningCardIds: learningCardIds ?? this.learningCardIds,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'topicId': topicId,
      'masteredCardIds': masteredCardIds,
      'learningCardIds': learningCardIds,
      'lastStudiedAt': lastStudiedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory FlashcardProgress.fromJson(Map<String, dynamic> json) {
    return FlashcardProgress(
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

  /// Create empty progress for a new topic
  factory FlashcardProgress.empty({
    required String userId,
    required String topicId,
    required List<String> allCardIds,
  }) {
    final now = DateTime.now();
    return FlashcardProgress(
      id: '${userId}_$topicId',
      userId: userId,
      topicId: topicId,
      masteredCardIds: [],
      learningCardIds: allCardIds,
      lastStudiedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'FlashcardProgress(id: $id, mastered: ${masteredCardIds.length}, learning: ${learningCardIds.length}, percentage: ${masteryPercentage.toStringAsFixed(1)}%)';
  }
}
