// lib/data/services/firebase_storage_service.dart

import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/toeic_question.dart';
import '../../domain/entities/toeic_test.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Base paths trong Firebase Storage
  static const String _jsonPath = 'toeic_data/questions.json';
  static const String _imagesPath = 'toeic_data/images/';
  static const String _audioPath = 'toeic_data/audio/';

  /// Load JSON data từ Firebase Storage
  static Future<Map<String, dynamic>> loadJsonData() async {
    try {
      print('🔥 Loading JSON from Firebase Storage...');
      
      // Get download URL của JSON file
      final ref = _storage.ref(_jsonPath);
      final downloadUrl = await ref.getDownloadURL();
      
      print('🔥 JSON download URL: $downloadUrl');
      
      // Download JSON content
      final response = await http.get(Uri.parse(downloadUrl));
      
      if (response.statusCode == 200) {
        final jsonString = response.body;
        print('🔥 JSON loaded successfully, length: ${jsonString.length}');
        
        final data = json.decode(jsonString);
        print('🔥 JSON parsed successfully');
        print('🔥 Available tests: ${data.keys.toList()}');
        
        return data;
      } else {
        throw Exception('Failed to load JSON: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading JSON from Firebase: $e');
      print('🔄 Falling back to local assets...');
      
      // Fallback to local assets if Firebase fails
      return await _loadLocalJsonData();
    }
  }

  /// Fallback method để load từ local assets
  static Future<Map<String, dynamic>> _loadLocalJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/toeic_questions.json');
      return json.decode(jsonString);
    } catch (e) {
      print('❌ Error loading local JSON: $e');
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
      name: testData['name'],
      description: 'TOEIC Practice Test',
      totalQuestions: testData['totalQuestions'],
      timeLimit: testData['timeLimit'],
      parts: (testData['parts'] as Map<String, dynamic>).keys.toList(),
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
      final partKey = 'part$partNumber';
      final partData = parts[partKey];

      if (partData == null) {
        print('❌ Part $partNumber not found');
        return [];
      }

      final questionsData = partData['questions'] as List<dynamic>;
      print('🔥 Loading ${questionsData.length} questions for part $partNumber from Firebase');

      final questions = <ToeicQuestion>[];

      for (var questionData in questionsData) {
        try {
          // Process images with Firebase URLs
          String? imageUrl;
          List<String>? imageUrls;

          if (questionData['imageFile'] != null) {
            imageUrl = await _getImageUrl(questionData['imageFile']);
          } else if (questionData['imageFiles'] != null && questionData['imageFiles'] is List) {
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

          // Process audio with Firebase URLs
          String? audioUrl;
          if (questionData['audioFile'] != null) {
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
            transcript: questionData['transcript'] ?? questionData['audioTranscript'],
            order: questionData['questionNumber'],
            groupId: questionData['groupId'],
            passageText: questionData['passageText'],
          );
          questions.add(question);
          
          print('✅ Processed question ${question.questionNumber} with Firebase URLs');
        } catch (e) {
          print('❌ Error creating question: $e');
        }
      }

      print('🔥 Successfully loaded ${questions.length} questions from Firebase');
      return questions;
    } catch (e) {
      print('❌ Error loading questions from Firebase: $e');
      return [];
    }
  }

  /// Get download URL cho image file
  static Future<String?> _getImageUrl(String imageFile) async {
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
    try {
      final ref = _storage.ref('$_audioPath$audioFile');
      return await ref.getDownloadURL();
    } catch (e) {
      print('❌ Error getting audio URL for $audioFile: $e');
      // Fallback to local asset
      return 'audio/toeic_test1/$audioFile';
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
  static Future<String?> uploadImage(String fileName, List<int> imageBytes) async {
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
  static Future<String?> uploadAudio(String fileName, List<int> audioBytes) async {
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
}