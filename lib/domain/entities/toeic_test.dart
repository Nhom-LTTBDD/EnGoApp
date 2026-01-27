/// toeicTest Entity - Model đại diện cho một BÀI THI TOEIC
///
/// ============================================================
/// MỤC ĐÍCH:
/// - Lưu trữ thông tin của một bài thi TOEIC
/// - Được load từ Firebase Storage
/// - Dùng để display danh sách bài thi và chi tiết bài thi
/// - Reference đến các câu hỏi (ToeicQuestion)
///
/// ============================================================
/// FIELD GIẢI THÍCH:
///
/// - id: String
///   Mã định danh duy nhất của bài thi (e.g., "test1", "test2")
///   Dùng để query từ Firebase Storage
///
/// - name: String
///   Tên bài thi hiển thị cho user (e.g., "TOEIC Test 1 - 2026")
///
/// - description: String
///   Mô tả chi tiết về bài thi
///
/// - totalQuestions: int
///   Tổng số câu hỏi trong bài
///   Listening: 100 câu (Part 1-4)
///   Reading: 100 câu (Part 5-7)
///
/// - listeningQuestions: int
///   Số câu hỏi listening (Part 1, 2, 3, 4)
///   Thường: 100
///
/// - readingQuestions: int
///   Số câu hỏi reading (Part 5, 6, 7)
///   Thường: 100
///
/// - duration: int
///   Thời gian làm bài tính bằng phút
///   Thường: 120 (2 tiếng)
///
/// - createdAt: DateTime
///   Ngày tạo bài thi trên Firebase
///
/// - updatedAt: DateTime
///   Ngày cập nhật bài thi gần nhất
///
/// - isActive: bool
///   Bài thi có hoạt động hay không
///   true = hiển thị được; false = ẩn đi
///
/// - year: int
///   Năm của bài thi (e.g., 2026)
///
/// ============================================================
/// CÁCH SỬ DỤNG:
///
/// 1. Load từ Firebase:
///    final test = await FirebaseStorageService.loadTest("test1");
///
/// 2. Display danh sách:
///    List<ToeicTest> tests = await ToeicSampleData.getAllTests();
///    tests.forEach((test) {
///      print("${test.name} - ${test.totalQuestions} câu");
///    });
///
/// 3. Tạo bản copy với thay đổi:
///    final updatedTest = test.copyWith(isActive: false);
///
/// ============================================================
/// EXAMPLE DATA:
///
/// ToeicTest(
///   id: "test1",
///   name: "TOEIC Test 1 - 2026",
///   description: "Full TOEIC test with 200 questions",
///   totalQuestions: 200,
///   listeningQuestions: 100,
///   readingQuestions: 100,
///   duration: 120,
///   createdAt: DateTime(2026, 1, 1),
///   updatedAt: DateTime(2026, 1, 27),
///   isActive: true,
///   year: 2026,
/// )
///
/// ============================================================

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

  /// 📋 copyWith() - Tạo bản copy với thay đổi một số field
  /// Dùng để immutability - tốt cho state management
  ///
  /// Example:
  /// final updatedTest = test.copyWith(
  ///   isActive: false,
  ///   year: 2027,
  /// );
  ///
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

  /// hashCode - Tạo hash code cho object
  /// Dùng khi lưu trữ ToeicTest trong Set, Map, v.v...
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

  /// 🖨️ toString() - Chuyển object thành string
  /// Dùng để debug, print, logging
  @override
  String toString() {
    return 'ToeicTest(id: $id, name: $name, description: $description, totalQuestions: $totalQuestions, listeningQuestions: $listeningQuestions, readingQuestions: $readingQuestions, duration: $duration, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, year: $year)';
  }
}
