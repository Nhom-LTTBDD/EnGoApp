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
        print('📁 File not found in Firebase Storage path: $_jsonPath');
        print('💡 Make sure to upload questions.json to Firebase Storage');
        throw Exception('Firebase Storage file not found: $_jsonPath');
      } else if (e.toString().contains('Permission denied')) {
        print('🚫 Permission denied - check Firebase Storage rules');
        throw Exception('Firebase Storage permission denied');
      } else if (e.toString().contains('Network') ||
          e.toString().contains('TimeoutException')) {
        print('🌐 Network error - check internet connection');
        throw Exception('Firebase Storage network error');
      } else {
        print('🔧 Unknown error - check Firebase configuration');
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
      print('Error loading local JSON: $e');
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
        print('❌ Test1 not found in data');
        return [];
      }

      final parts = testData['parts'];
      // Try both string and integer keys
      final partKey = partNumber.toString();
      final partData = parts[partKey] ?? parts[partNumber];

      if (partData == null) {
        print(
          '❌ Part $partNumber not found (tried keys: "$partKey" and $partNumber)',
        );
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
          print('❌ Error creating question: $e');
        }
      }

      return questions;
    } catch (e) {
      print('❌ Error loading questions from Firebase: $e');
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
      print('❌ Error getting image URL for $imageFile: $e');
      // Fallback to local asset
      return 'assets/test_toeic/test_1/$imageFile';
    }
  }

  /// Get download URL cho audio file
  static Future<String?> _getAudioUrl(String audioFile) async {
    if (!_useFirebaseStorage) {
      // Return local asset path when Firebase Storage is disabled
      return 'assets/audio/toeic_test1/$audioFile';
    }

    try {
      final ref = _storage.ref('$_audioPath$audioFile');
      return await ref.getDownloadURL();
    } catch (e) {
      print('❌ Error getting audio URL for $audioFile: $e');
      // Fallback to local asset
      return 'assets/audio/toeic_test1/$audioFile';
    }
  }

  /// Upload JSON data to Firebase Storage
  static Future<void> uploadJsonData(Map<String, dynamic> jsonData) async {
    try {
      print('🔥 Uploading JSON data to Firebase Storage...');

      final jsonString = json.encode(jsonData);
      final ref = _storage.ref(_jsonPath);

      await ref.putString(jsonString, format: PutStringFormat.raw);
      print('✅ JSON data uploaded successfully');
    } catch (e) {
      print('❌ Error uploading JSON data: $e');
      rethrow;
    }
  }

  /// Upload image file to Firebase Storage
  static Future<String?> uploadImage(
    String fileName,
    List<int> imageBytes,
  ) async {
    try {
      print('🔥 Uploading image $fileName to Firebase Storage...');

      final ref = _storage.ref('$_imagesPath$fileName');
      await ref.putData(Uint8List.fromList(imageBytes));

      final downloadUrl = await ref.getDownloadURL();
      print('✅ Image $fileName uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image $fileName: $e');
      return null;
    }
  }

  /// Upload audio file to Firebase Storage
  static Future<String?> uploadAudio(
    String fileName,
    List<int> audioBytes,
  ) async {
    try {
      print('🔥 Uploading audio $fileName to Firebase Storage...');

      final ref = _storage.ref('$_audioPath$fileName');
      await ref.putData(Uint8List.fromList(audioBytes));

      final downloadUrl = await ref.getDownloadURL();
      print('✅ Audio $fileName uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading audio $fileName: $e');
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
      print('❌ Error getting metadata for $path: $e');
      return null;
    }
  }

  /// Delete file from Firebase Storage
  static Future<bool> deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
      print('🗑️ Deleted: $path');
      return true;
    } catch (e) {
      print('❌ Error deleting $path: $e');
      return false;
    }
  }

  /// Delete all files in a folder
  static Future<void> deleteFolder(String folderPath) async {
    try {
      print('🗑️ Deleting folder: $folderPath');
      final ref = _storage.ref(folderPath);
      final listResult = await ref.listAll();

      // Delete all files
      for (final item in listResult.items) {
        await item.delete();
        print('🗑️ Deleted file: ${item.name}');
      }

      // Delete all subfolders recursively
      for (final prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }

      print('✅ Folder deleted: $folderPath');
    } catch (e) {
      print('❌ Error deleting folder $folderPath: $e');
    }
  }

  /// Clean up old data structure
  static Future<void> cleanupOldData() async {
    try {
      print('🧹 Attempting to clean up old data structure...');

      // Delete old structure if exists - but continue even if fails
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
          print('⚠️ Could not delete $path: $e (continuing anyway...)');
        }
      }

      print('✅ Cleanup attempt completed (some files may remain)');
    } catch (e) {
      print('⚠️ Cleanup failed but continuing with upload: $e');
    }
  }

  /// Resolve Firebase Storage references to download URLs
  /// Chuyển đổi references thành download URLs để sử dụng

  /// Get download URL for image file
  static Future<String?> getImageDownloadUrl(String imageFile) async {
    if (!_useFirebaseStorage) return null;

    try {
      // Convert jpg extension to png since files are stored as .png
      String pngFileName = imageFile.replaceAll('.jpg', '.png');

      // Tắt debug logging để tránh spam khi cache hoạt động
      // print('🔍 Searching for image: $imageFile -> $pngFileName');
      // print('🔍 Full path: $_imagesPath$pngFileName');

      final ref = _storage.ref('$_imagesPath$pngFileName');
      final downloadUrl = await ref.getDownloadURL().timeout(
        const Duration(seconds: 5),
      );
      // print('✅ Image found at: $_imagesPath$pngFileName');
      return downloadUrl;
    } catch (e) {
      print('❌ Error getting image URL for $imageFile: $e');

      // Debug: list files in images directory (chỉ khi có lỗi)
      try {
        print('🔍 Listing files in images directory...');
        final ref = _storage.ref(_imagesPath);
        final listResult = await ref.listAll();
        print('📁 Found ${listResult.items.length} files in images directory:');
        for (var item in listResult.items) {
          print('  - ${item.name}');
        }
      } catch (listError) {
        print('❌ Error listing images directory: $listError');
      }

      return null;
    }
  }

  /// Get download URL for audio file
  static Future<String?> getAudioDownloadUrl(String audioFile) async {
    if (!_useFirebaseStorage) return null;

    try {
      final ref = _storage.ref('$_audioPath$audioFile');
      final downloadUrl = await ref.getDownloadURL().timeout(
        const Duration(seconds: 5),
      );
      print('🎵 Audio URL resolved: $audioFile');
      return downloadUrl;
    } catch (e) {
      print('❌ Error getting audio URL for $audioFile: $e');
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
