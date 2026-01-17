// lib/domain/entities/user_streak.dart

/// Entity đại diện cho chuỗi học liên tiếp của user
class UserStreak {
  final String userId;
  final int currentStreak; // Chuỗi hiện tại (số ngày)
  final int longestStreak; // Chuỗi dài nhất từng đạt được
  final DateTime? lastActivityDate; // Ngày hoạt động cuối cùng
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStreak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copy with method
  UserStreak copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStreak(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory: Tạo streak mới cho user lần đầu
  factory UserStreak.initial(String userId) {
    final now = DateTime.now();
    return UserStreak(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      lastActivityDate: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Convert to JSON (cho Firebase/SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      userId: json['userId'] as String,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'UserStreak(userId: $userId, current: $currentStreak, longest: $longestStreak)';
  }
}
