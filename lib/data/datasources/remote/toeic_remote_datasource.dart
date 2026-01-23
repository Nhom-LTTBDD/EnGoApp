// lib/data/datasources/remote/toeic_remote_datasource.dart
// Remote data source để tương tác với Firebase cho dữ liệu TOEIC
// Bao gồm: upload/download tests, questions, và audio files

// Import để làm việc với files
import 'dart:io';
// Firebase services
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Data models cho TOEIC
import '../../models/toeic_test_model.dart';
import '../../models/toeic_question_model.dart';
// Constants định nghĩa tên collections trong Firebase
import '../../../core/constants/firebase_collections.dart';

// Abstract class định nghĩa contract cho remote data source
// Sử dụng abstract để đảm bảo implementation tuân thủ interface
abstract class ToeicRemoteDatasource {
  // Method upload thông tin test lên Firestore
  Future<void> uploadToeicTest(ToeicTestModel test);

  // Method upload danh sách questions lên Firestore (batch operation)
  Future<void> uploadToeicQuestions(List<ToeicQuestionModel> questions);

  // Method upload file audio lên Firebase Storage và trả về download URL
  Future<String> uploadAudioFile(
    File audioFile, // File audio cần upload
    String testId, // ID của test
    int questionNumber, // Số thứ tự câu hỏi
  );

  // Method lấy thông tin test từ Firestore
  Future<ToeicTestModel?> getToeicTest(String testId);

  // Method lấy tất cả questions của một test
  Future<List<ToeicQuestionModel>> getToeicQuestions(String testId);

  // Method lấy questions theo các parts cụ thể
  Future<List<ToeicQuestionModel>> getToeicQuestionsByParts(
    String testId, // ID của test
    List<int> partNumbers, // Danh sách part numbers cần lấy
  );
}

// Implementation concrete class của ToeicRemoteDatasource
// Sử dụng Firebase Firestore và Storage để thực hiện các operations
class ToeicRemoteDatasourceImpl implements ToeicRemoteDatasource {
  // Private instances của Firebase services
  final FirebaseFirestore _firestore; // Firestore để lưu structured data
  final FirebaseStorage _storage; // Storage để lưu files (audio, images)

  // Constructor với dependency injection
  // Cho phép inject mock instances cho testing
  ToeicRemoteDatasourceImpl({
    FirebaseFirestore? firestore, // Optional, dùng default instance nếu null
    FirebaseStorage? storage, // Optional, dùng default instance nếu null
  }) : _firestore =
           firestore ??
           FirebaseFirestore
               .instance, // Sử dụng singleton instance nếu không inject
       _storage =
           storage ??
           FirebaseStorage
               .instance; // Sử dụng singleton instance nếu không inject

  // Method upload thông tin test (metadata) lên Firestore
  @override
  Future<void> uploadToeicTest(ToeicTestModel test) async {
    try {
      // Tạo document trong collection 'toeic_tests' với ID là test.id
      await _firestore
          .collection(
            FirebaseCollections.toeicTests,
          ) // Collection name từ constants
          .doc(test.id) // Document ID là test ID
          .set(test.toJson()); // Convert model thành JSON để lưu
    } catch (e) {
      // Wrap exception với message rõ ràng để debug dễ hơn
      throw Exception('Failed to upload TOEIC test: $e');
    }
  }

  // Method upload danh sách questions lên Firestore sử dụng batch operation
  // Batch giúp upload nhiều documents cùng lúc, atomic và hiệu quả hơn
  @override
  Future<void> uploadToeicQuestions(List<ToeicQuestionModel> questions) async {
    try {
      // Tạo batch để nhóm nhiều write operations
      final batch = _firestore.batch();

      // Duyệt qua từng question và thêm vào batch
      for (final question in questions) {
        // Tạo document reference trong collection 'toeic_questions'
        final docRef = _firestore
            .collection(FirebaseCollections.toeicQuestions)
            .doc(question.id); // Document ID là question ID

        // Thêm set operation vào batch
        batch.set(docRef, question.toJson());
      }

      // Commit tất cả operations trong batch một lần
      // Nếu có lỗi, tất cả sẽ rollback (atomic operation)
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to upload TOEIC questions: $e');
    }
  }

  // Method upload file audio lên Firebase Storage
  @override
  Future<String> uploadAudioFile(
    File audioFile, // File audio từ local storage
    String testId, // ID của test để tổ chức folder
    int questionNumber, // Số câu hỏi để đặt tên file
  ) async {
    try {
      // Tạo tên file chuẩn: q001.mp3, q002.mp3, etc.
      final fileName = 'q${questionNumber.toString().padLeft(3, '0')}.mp3';

      // Tạo reference đến vị trí trong Storage
      // Structure: toeic_audio/test1/q001.mp3
      final ref = _storage.ref().child('toeic_audio/$testId/$fileName');

      // Upload file lên Storage
      final uploadTask = await ref.putFile(audioFile);

      // Lấy download URL để access file từ app
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl; // Trả về URL để lưu vào database
    } catch (e) {
      throw Exception('Failed to upload audio file: $e');
    }
  }

  // Method lấy thông tin test từ Firestore
  @override
  Future<ToeicTestModel?> getToeicTest(String testId) async {
    try {
      // Lấy document từ collection sử dụng testId
      final doc = await _firestore
          .collection(FirebaseCollections.toeicTests)
          .doc(testId) // Tìm document theo ID
          .get();

      // Kiểm tra document có tồn tại không
      if (!doc.exists) return null;

      // Convert data từ Firestore thành model object
      // Thêm ID vào data vì Firestore không auto include ID
      return ToeicTestModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get TOEIC test: $e');
    }
  }

  // Method lấy tất cả questions của một test, sắp xếp theo thứ tự
  @override
  Future<List<ToeicQuestionModel>> getToeicQuestions(String testId) async {
    try {
      // Query questions có testId khớp, sắp xếp theo field 'order'
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.toeicQuestions)
          .where('testId', isEqualTo: testId) // Filter theo testId
          .orderBy('order') // Sắp xếp theo thứ tự câu hỏi
          .get();

      // Convert từng document thành model object
      return querySnapshot.docs
          .map(
            (doc) => ToeicQuestionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get TOEIC questions: $e');
    }
  }

  // Method lấy questions của các parts cụ thể
  @override
  Future<List<ToeicQuestionModel>> getToeicQuestionsByParts(
    String testId,
    List<int> partNumbers, // Danh sách part numbers cần lấy
  ) async {
    try {
      // Query với nhiều điều kiện: testId và partNumber trong danh sách
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.toeicQuestions)
          .where('testId', isEqualTo: testId) // Filter theo testId
          .where('partNumber', whereIn: partNumbers) // Filter theo list parts
          .orderBy('order') // Sắp xếp theo thứ tự
          .get();

      // Convert documents thành list of models
      return querySnapshot.docs
          .map(
            (doc) => ToeicQuestionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get TOEIC questions by parts: $e');
    }
  }
}
