/// ToeicSampleData - Data Source cho TOEIC
/// MỤC ĐÍCH:
/// - Cung cấp dữ liệu TOEIC: tests, questions, parts info
/// - Là bridge giữa UI (presentation) và dữ liệu thực (services)
/// - Xử lý lỗi khi load dữ liệu từ Firebase/JSON
/// - Trả về fallback data nếu load fails (app không crash)
import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';
import '../services/toeic_json_service.dart';

/// Class chứa các static methods để cung cấp dữ liệu TOEIC
/// Tất cả methods đều return Future (async) vì load dữ liệu từ Firebase
class ToeicSampleData {
  /// Gọi ToeicJsonService.loadTest() để fetch dữ liệu từ Firebase Storage
  /// Firebase path: toeic_data/test_1_2026/questions.json
  /// - Fallback data không chính xác nhưng app vẫn chạy
  static Future<ToeicTest> getPracticeTest1() async {
    try {
      // Gọi service để load test từ Firebase/local JSON
      return await ToeicJsonService.loadTest('test1');
    } catch (e) {
      // Nếu load fails, trả về default test data để app không crash
      return ToeicTest(
        id: 'test1',
        name: 'TOEIC Practice Test 1',
        description: 'TOEIC Practice Test',
        totalQuestions: 200,
        listeningQuestions: 100,
        readingQuestions: 100,
        duration: 120,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        year: 2026,
      );
    }
  }

  /// Static data định nghĩa cấu trúc 7 parts của TOEIC
  /// Dùng để:
  /// - Hiển thị tên part trên UI
  /// - Hiển thị số câu hỏi
  /// - Navigation giữa các part
  static final List<Map<String, dynamic>> parts = [
    {'number': 1, 'name': 'Part 1', 'questionCount': 6, 'type': 'Photographs'},
    {
      'number': 2,
      'name': 'Part 2',
      'questionCount': 25,
      'type': 'Question-Response',
    },
    {
      'number': 3,
      'name': 'Part 3',
      'questionCount': 39,
      'type': 'Conversations',
    },
    {'number': 4, 'name': 'Part 4', 'questionCount': 30, 'type': 'Talks'},
    {
      'number': 5,
      'name': 'Part 5',
      'questionCount': 30,
      'type': 'Incomplete Sentences',
    },
    {
      'number': 6,
      'name': 'Part 6',
      'questionCount': 16,
      'type': 'Text Completion',
    },
    {
      'number': 7,
      'name': 'Part 7',
      'questionCount': 54,
      'type': 'Reading Comprehension',
    },
  ];

  /// Load questions cho một part cụ thể (1-7)
  ///
  /// Parameters:
  /// - partNumber: Số part cần load (1-7)
  ///
  /// Return:
  /// - List<ToeicQuestion>: Danh sách câu hỏi của part đó
  /// - Empty list [] nếu lỗi hoặc không có data
  ///
  /// Flow:
  /// 1. Gọi ToeicJsonService.loadQuestionsByPart('test1', partNumber)
  /// 2. Service load từ Firebase Storage:
  ///    - Firebase path: toeic_data/test_1_2026/questions.json
  ///    - Parse JSON → Lọc câu theo part
  /// 3. Return List<ToeicQuestion>
  ///
  /// Error handling:
  /// - Nếu Firebase fails → Catch exception
  /// - Trả về empty list [] thay vì crash app
  /// - UI có thể handle empty list gracefully (hiển thị "No questions")
  static Future<List<ToeicQuestion>> getQuestionsByPart(int partNumber) async {
    try {
      // Gọi ToeicJsonService để load questions từ Firebase
      // Service sẽ:
      // 1. Resolve Firebase URL
      // 2. Download JSON file
      // 3. Parse JSON thành ToeicQuestion objects
      // 4. Filter theo partNumber
      final questions = await ToeicJsonService.loadQuestionsByPart(
        'test1',
        partNumber,
      );
      if (questions.isEmpty) {
        // Trả về empty list thay vì throw exception để tránh crash app
        return [];
      }
      return questions;
    } catch (e) {
      // Error handling: Catch bất kỳ exception nào
      // Có thể là:
      // - Firebase connection error
      // - JSON parsing error
      // - Network error
      // Không log hay throw, chỉ trả về empty list
      // Làm này tránh app crash, UI vẫn render được (just hiển thị rỗng)
      return [];
    }
  }

  /// Load tất cả questions từ test (all 7 parts) một lúc
  /// Flow:
  /// 1. Gọi ToeicJsonService.loadAllQuestions('test1')
  /// 2. Service load JSON từ Firebase
  /// 3. Parse tất cả 200 câu (không filter part)
  /// 4. Return List<ToeicQuestion> (length = 200)
  ///
  /// Performance:
  /// - Load tất cả 200 câu cùng lúc
  /// - Chậm hơn getQuestionsByPart (chỉ load 1 part)
  ///
  /// Ví dụ:
  ///   final allQuestions = await ToeicSampleData.getAllQuestions();
  ///   print(allQuestions.length); // 200
  static Future<List<ToeicQuestion>> getAllQuestions() async {
    try {
      // Gọi service để load tất cả questions của test
      // Service sẽ load JSON file từ Firebase + parse tất cả
      final questions = await ToeicJsonService.loadAllQuestions('test1');

      // Kiểm tra và trả về kết quả
      if (questions.isEmpty) {
        // Trả về empty list nếu không có data
        return [];
      }
      // Trả về 200 câu hỏi
      return questions;
    } catch (e) {
      // Error handling: trả về empty list thay vì crash
      // Tránh app crash khi load dữ liệu fails
      return [];
    }
  }
}
