// lib/data/services/firebase_storage_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Flag to control Firebase Storage usage
  static bool _useFirebaseStorage = true;

  /// Enable Firebase Storage (default state)
  static void enableFirebaseStorage() {
    _useFirebaseStorage = true;
  }

  /// Disable Firebase Storage for fallback scenarios
  static void disableFirebaseStorage() {
    _useFirebaseStorage = false;
  }

  // Base paths trong Firebase Storage - gs://engoapp-91373.firebasestorage.app
  static const String _testFolder = 'test_1_2026';
  static const String _basePath = 'toeic_data/$_testFolder';
  static const String _jsonPath = '$_basePath/questions.json';
  static const String _imagesPath = '$_basePath/images/';
  static const String _audioPath = '$_basePath/audio/';

  /// Load JSON data từ Firebase Storage
  static Future<Map<String, dynamic>> loadJsonData() async {
    if (!_useFirebaseStorage) {
      return await _loadLocalJsonData();
    }

    try {
      // Get download URL của JSON file với timeout
      final ref = _storage.ref(_jsonPath);
      final downloadUrl = await ref.getDownloadURL().timeout(
        const Duration(seconds: 5),
      );

      // Download JSON content với timeout
      final response = await http
          .get(Uri.parse(downloadUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonString = response.body;

        final data = json.decode(jsonString);

        return data;
      } else {
        throw Exception('Failed to load JSON: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Object not found') ||
          e.toString().contains('object-not-found') ||
          e.toString().contains('404')) {
        throw Exception('Firebase Storage file not found: $_jsonPath');
      } else if (e.toString().contains('Permission denied')) {
        throw Exception('Firebase Storage permission denied');
      } else if (e.toString().contains('Network') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Firebase Storage network error');
      } else {
        throw Exception('Firebase Storage configuration error: $e');
      }
    }
  }

  /// Fallback method để load từ local assets
  static Future<Map<String, dynamic>> _loadLocalJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/toeic_questions.json',
      );
      return json.decode(jsonString);
    } catch (e) {
      return {};
    }
  }

  /// Load TOEIC test từ Firebase
  static Future<ToeicTest> loadTest(String testId) async {
    final data = await loadJsonData();
    final testData = data[testId];

    if (testData == null) {
      throw Exception('Test $testId not found');
    }

    return ToeicTest(
      id: testId,
      name: testData['name'] ?? 'TOEIC Practice Test',
      description: 'TOEIC Practice Test',
      totalQuestions: testData['totalQuestions'] ?? 200,
      listeningQuestions: 100, // Parts 1-4
      readingQuestions: 100, // Parts 5-7
      duration: testData['timeLimit'] ?? testData['duration'] ?? 120, // 2 hours
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      year: 2025,
    );
  }

  /// Load questions cho một part cụ thể
  static Future<List<ToeicQuestion>> loadQuestionsByPart(int partNumber) async {
    try {
      final data = await loadJsonData();
      final testData = data['test1'];

      if (testData == null) {
        return [];
      }

      final parts = testData['parts'];
      // Try both string and integer keys
      final partKey = partNumber.toString();
      final partData = parts[partKey] ?? parts[partNumber];

      if (partData == null) {
        return [];
      }

      final questionsData = partData['questions'] as List<dynamic>;

      final questions = <ToeicQuestion>[];

      for (var questionData in questionsData) {
        try {
          // Process images with Firebase URLs only if enabled
          String? imageUrl;
          List<String>? imageUrls;

          if (_useFirebaseStorage) {
            if (questionData['imageFile'] != null) {
              imageUrl = await _getImageUrl(questionData['imageFile']);
            } else if (questionData['imageFiles'] != null &&
                questionData['imageFiles'] is List) {
              imageUrls = [];
              for (String imageFile in questionData['imageFiles']) {
                final url = await _getImageUrl(imageFile);
                if (url != null) {
                  imageUrls.add(url);
                }
              }
              if (imageUrls.isNotEmpty) {
                imageUrl = imageUrls.first;
              }
            }
          }

          // Process audio with Firebase URLs only if enabled
          String? audioUrl;
          if (_useFirebaseStorage && questionData['audioFile'] != null) {
            audioUrl = await _getAudioUrl(questionData['audioFile']);
          }

          final question = ToeicQuestion(
            id: 'q${questionData['questionNumber']}',
            testId: 'test1',
            partNumber: partNumber,
            questionNumber: questionData['questionNumber'],
            questionType: questionData['questionType'] ?? 'multiple-choice',
            questionText: questionData['questionText'],
            imageUrl: imageUrl,
            imageUrls: imageUrls,
            audioUrl: audioUrl,
            options: List<String>.from(questionData['options'] ?? []),
            correctAnswer: questionData['correctAnswer'] ?? 'A',
            explanation: questionData['explanation'] ?? '',
            transcript:
                questionData['transcript'] ?? questionData['audioTranscript'],
            order: questionData['questionNumber'],
            groupId: questionData['groupId'],
            passageText: questionData['passageText'],
          );
          questions.add(question);
        } catch (e) {
          // Ignore errors for individual questions
        }
      }

      return questions;
    } catch (e) {
      return [];
    }
  }

  /// Get download URL cho image file
  static Future<String?> _getImageUrl(String imageFile) async {
    if (!_useFirebaseStorage) {
      // Return local asset path when Firebase Storage is disabled
      return 'assets/test_toeic/test_1/$imageFile';
    }

    try {
      final ref = _storage.ref('$_imagesPath$imageFile');
      return await ref.getDownloadURL();
    } catch (e) {
      return 'assets/test_toeic/test_1/$imageFile';
    }
  }

  /// Get download URL cho audio file
  static Future<String?> _getAudioUrl(String audioFile) async {
    if (!_useFirebaseStorage) {
      return 'assets/audio/toeic_test1/$audioFile';
    }

    try {
      final ref = _storage.ref('$_audioPath$audioFile');
      return await ref.getDownloadURL();
    } catch (e) {
      return 'assets/audio/toeic_test1/$audioFile';
    }
  }

  /// Upload JSON data to Firebase Storage
  static Future<void> uploadJsonData(Map<String, dynamic> jsonData) async {
    try {
      final jsonString = json.encode(jsonData);
      final ref = _storage.ref(_jsonPath);
      await ref.putString(jsonString, format: PutStringFormat.raw);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image file to Firebase Storage
  static Future<String?> uploadImage(
    String fileName,
    List<int> imageBytes,
  ) async {
    try {
      final ref = _storage.ref('$_imagesPath$fileName');
      await ref.putData(Uint8List.fromList(imageBytes));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Upload audio file to Firebase Storage
  static Future<String?> uploadAudio(
    String fileName,
    List<int> audioBytes,
  ) async {
    try {
      final ref = _storage.ref('$_audioPath$fileName');
      await ref.putData(Uint8List.fromList(audioBytes));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Check if file exists in Firebase Storage
  static Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata
  static Future<FullMetadata?> getFileMetadata(String path) async {
    try {
      final ref = _storage.ref(path);
      return await ref.getMetadata();
    } catch (e) {
      return null;
    }
  }

  /// Delete file from Firebase Storage
  static Future<bool> deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete all files in a folder
  static Future<void> deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref(folderPath);
      final listResult = await ref.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }

      for (final prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clean up old data structure
  static Future<void> cleanupOldData() async {
    try {
      final oldPaths = [
        'toeic_data/questions.json',
        'toeic_data/images',
        'toeic_data/audio',
      ];

      for (String path in oldPaths) {
        try {
          if (await fileExists(path)) {
            if (path.contains('.json')) {
              await deleteFile(path);
            } else {
              await deleteFolder(path);
            }
          }
        } catch (e) {
          // Continue even if deletion fails
        }
      }
    } catch (e) {
      // Continue with upload
    }
  }

  /// Resolve Firebase Storage references to download URLs
  /// Chuyển đổi references thành download URLs để sử dụng

  /// Get download URL for image file
  static Future<String?> getImageDownloadUrl(String imageFile) async {
    if (!_useFirebaseStorage) return null;

    try {
      String pngFileName = imageFile.replaceAll('.jpg', '.png');
      final ref = _storage.ref('$_imagesPath$pngFileName');
      return await ref.getDownloadURL().timeout(const Duration(seconds: 5));
    } catch (e) {
      return null;
    }
  }

  /// Get download URL for audio file
  static Future<String?> getAudioDownloadUrl(String audioFile) async {
    if (!_useFirebaseStorage) return null;

    try {
      final ref = _storage.ref('$_audioPath$audioFile');
      return await ref.getDownloadURL().timeout(const Duration(seconds: 5));
    } catch (e) {
      return null;
    }
  }

  /// Helper method to resolve any Firebase reference to download URL
  static Future<String?> resolveFirebaseUrl(String firebaseReference) async {
    if (firebaseReference.startsWith('firebase_image:')) {
      final fileName = firebaseReference.replaceFirst('firebase_image:', '');
      return await getImageDownloadUrl(fileName);
    } else if (firebaseReference.startsWith('firebase_audio:')) {
      final fileName = firebaseReference.replaceFirst('firebase_audio:', '');
      return await getAudioDownloadUrl(fileName);
    }
    return null;
  }
}
