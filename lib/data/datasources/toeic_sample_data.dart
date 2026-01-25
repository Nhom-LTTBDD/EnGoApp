// lib/data/datasources/toeic_sample_data.dart
// Data source class cung cấp dữ liệu TOEIC cho ứng dụng
// Bao gồm: thông tin test, parts, và questions từ JSON/Firebase

// Import entities để định nghĩa cấu trúc dữ liệu
import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';
// Import service để load dữ liệu từ JSON/Firebase
import '../services/toeic_json_service.dart';

// Class chứa các static methods để cung cấp dữ liệu TOEIC
class ToeicSampleData {
  // Method load thông tin test (metadata) từ JSON service
  static Future<ToeicTest> getPracticeTest1() async {
    try {
      // Gọi service để load test từ Firebase/local JSON
      return await ToeicJsonService.loadTest('test1');
    } catch (e) {
      // Nếu load fails, trả về default test data để app không crash
      return ToeicTest(
        id: 'test1', // ID định danh test
        name: 'TOEIC Practice Test 1', // Tên hiển thị
        description: 'TOEIC Practice Test', // Mô tả test
        totalQuestions: 200, // Tổng số câu hỏi (standard TOEIC)
        listeningQuestions: 100, // Số câu Listening (Part 1-4)
        readingQuestions: 100, // Số câu Reading (Part 5-7)
        duration: 120, // Thời gian làm bài (phút)
        createdAt: DateTime.now(), // Thời gian tạo
        updatedAt: DateTime.now(), // Thời gian cập nhật
        isActive: true, // Trạng thái active của test
        year: 2026, // Năm của test
      );
    }
  }

  // Static data định nghĩa cấu trúc 7 parts của TOEIC
  // Được sử dụng cho navigation và hiển thị thông tin parts
  static final List<Map<String, dynamic>> parts = [
    // LISTENING SECTION (Parts 1-4)
    {
      'number': 1, // Số thứ tự part
      'name': 'Part 1', // Tên hiển thị
      'questionCount': 6, // Số câu hỏi trong part này
      'type': 'Photographs', // Loại câu hỏi (mô tả hình ảnh)
    },
    {
      'number': 2,
      'name': 'Part 2',
      'questionCount': 25,
      'type': 'Question-Response', // Câu hỏi - phản hồi
    },
    {
      'number': 3,
      'name': 'Part 3',
      'questionCount': 39,
      'type': 'Conversations', // Đoạn hội thoại
    },
    {
      'number': 4,
      'name': 'Part 4',
      'questionCount': 30,
      'type': 'Talks', // Đoạn nói chuyện
    },
    // READING SECTION (Parts 5-7)
    {
      'number': 5,
      'name': 'Part 5',
      'questionCount': 30,
      'type': 'Incomplete Sentences', // Câu chưa hoàn chỉnh
    },
    {
      'number': 6,
      'name': 'Part 6',
      'questionCount': 16,
      'type': 'Text Completion', // Hoàn thành đoạn văn
    },
    {
      'number': 7,
      'name': 'Part 7',
      'questionCount': 54,
      'type': 'Reading Comprehension', // Đọc hiểu
    },
  ];

  // Method load questions cho một part cụ thể
  // Input: partNumber (1-7)
  // Output: List<ToeicQuestion> hoặc empty list nếu lỗi
  static Future<List<ToeicQuestion>> getQuestionsByPart(int partNumber) async {
    try {
      // Gọi ToeicJsonService để load questions từ Firebase
      final questions = await ToeicJsonService.loadQuestionsByPart(
        'test1', // Test ID
        partNumber, // Part number (1-7)
      );

      // Kiểm tra nếu không có questions được load
      if (questions.isEmpty) {
        // Trả về empty list thay vì throw exception để tránh crash app
        return [];
      }

      return questions;
    } catch (e) {
      // Error handling: log lỗi nhưng không crash app
      // Trả về empty list để UI có thể handle gracefully
      return [];
    }
  }

  // Method load tất cả questions từ test (all 7 parts)
  // Được sử dụng khi cần load full test hoặc tính toán tổng thể
  static Future<List<ToeicQuestion>> getAllQuestions() async {
    try {
      // Gọi service để load tất cả questions của test
      final questions = await ToeicJsonService.loadAllQuestions('test1');

      // Kiểm tra và trả về kết quả
      if (questions.isEmpty) {
        return []; // Trả về empty list nếu không có data
      }
      return questions;
    } catch (e) {
      // Error handling: trả về empty list thay vì crash
      return [];
    }
  }
}
