// lib/data/models/personal_vocabulary_model.dart

/// # PersonalVocabularyModel - Data Layer
/// 
/// **Purpose:** Model lưu trữ danh sách card IDs đã được user bookmark
/// **Architecture Layer:** Data (Model)
/// **Key Features:**
/// - Track vocabularyCardIds (list of bookmarked card IDs)
/// - Add/remove/toggle bookmark operations
/// - Immutable với copyWith pattern
/// - JSON serialization cho storage
/// 
/// **Usage:** Service layer sử dụng để sync với SharedPreferences và Firestore

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
  /// Copy với new values (immutable pattern)
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
  /// Kiểm tra card đã được bookmark chưa
  bool isBookmarked(String cardId) {
    return vocabularyCardIds.contains(cardId);
  }

  /// Thêm card vào bookmarks (immutable - trả về instance mới)
  PersonalVocabularyModel addCard(String cardId) {
    if (vocabularyCardIds.contains(cardId)) {
      return this;
    }
    return copyWith(
      vocabularyCardIds: [...vocabularyCardIds, cardId],
      updatedAt: DateTime.now(),
    );
  }
  /// Xóa card khỏi bookmarks (immutable - trả về instance mới)
  PersonalVocabularyModel removeCard(String cardId) {
    return copyWith(
      vocabularyCardIds: vocabularyCardIds.where((id) => id != cardId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Toggle bookmark status (add nếu chưa có, remove nếu đã có)
  PersonalVocabularyModel toggleBookmark(String cardId) {
    if (vocabularyCardIds.contains(cardId)) {
      return removeCard(cardId);
    } else {
      return addCard(cardId);
    }
  }
  /// Serialize sang JSON cho storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vocabularyCardIds': vocabularyCardIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  /// Deserialize từ JSON
  factory PersonalVocabularyModel.fromJson(Map<String, dynamic> json) {
    return PersonalVocabularyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vocabularyCardIds: List<String>.from(json['vocabularyCardIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  /// Factory tạo empty model cho user mới
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
