// lib/data/services/firebase_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/test_history.dart';

class FirebaseFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _testHistoryCollection = 'test_history';

  /// Save test history to Firestore
  static Future<void> saveTestHistory(TestHistory history) async {
    try {
      print('💾 Saving test history to Firestore...');

      await _firestore
          .collection(_testHistoryCollection)
          .doc(history.id)
          .set(history.toMap());

      print('Test history saved successfully: ${history.id}');
    } catch (e) {
      print('Error saving test history: $e');
      rethrow;
    }
  }

  /// Get test history by user ID
  static Future<List<TestHistory>> getTestHistoryByUser(String userId) async {
    try {
      print('📚 Loading test history for user: $userId');

      final querySnapshot = await _firestore
          .collection(_testHistoryCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      final histories = querySnapshot.docs
          .map((doc) => TestHistory.fromMap(doc.data()))
          .toList();

      print('Loaded ${histories.length} test histories');
      return histories;
    } catch (e) {
      print('Error loading test history: $e');
      return [];
    }
  }

  /// Get specific test history by ID
  static Future<TestHistory?> getTestHistoryById(String historyId) async {
    try {
      print('Loading test history: $historyId');

      final doc = await _firestore
          .collection(_testHistoryCollection)
          .doc(historyId)
          .get();

      if (doc.exists) {
        return TestHistory.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error loading test history by ID: $e');
      return null;
    }
  }

  /// Get test histories by test ID (all users)
  static Future<List<TestHistory>> getTestHistoryByTestId(String testId) async {
    try {
      print('📋 Loading histories for test: $testId');

      final querySnapshot = await _firestore
          .collection(_testHistoryCollection)
          .where('testId', isEqualTo: testId)
          .orderBy('totalScore', descending: true)
          .get();

      final histories = querySnapshot.docs
          .map((doc) => TestHistory.fromMap(doc.data()))
          .toList();

      print('✅ Loaded ${histories.length} test histories for $testId');
      return histories;
    } catch (e) {
      print('❌ Error loading test histories by test ID: $e');
      return [];
    }
  }

  /// Delete test history
  static Future<void> deleteTestHistory(String historyId) async {
    try {
      print('🗑️ Deleting test history: $historyId');

      await _firestore
          .collection(_testHistoryCollection)
          .doc(historyId)
          .delete();

      print('✅ Test history deleted successfully');
    } catch (e) {
      print('❌ Error deleting test history: $e');
      rethrow;
    }
  }

  /// Get user's best score for a test
  static Future<TestHistory?> getUserBestScore(
    String userId,
    String testId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_testHistoryCollection)
          .where('userId', isEqualTo: userId)
          .where('testId', isEqualTo: testId)
          .orderBy('totalScore', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return TestHistory.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('❌ Error getting user best score: $e');
      return null;
    }
  }

  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final histories = await getTestHistoryByUser(userId);

      if (histories.isEmpty) {
        return {
          'totalTests': 0,
          'averageScore': 0.0,
          'bestScore': 0,
          'totalTimeSpent': 0,
          'averageAccuracy': 0.0,
        };
      }

      final totalTests = histories.length;
      final averageScore =
          histories.map((h) => h.totalScore).reduce((a, b) => a + b) /
          totalTests;
      final bestScore = histories
          .map((h) => h.totalScore)
          .reduce((a, b) => a > b ? a : b);
      final totalTimeSpent = histories
          .map((h) => h.timeSpent)
          .reduce((a, b) => a + b);
      final averageAccuracy =
          histories.map((h) => h.accuracyPercentage).reduce((a, b) => a + b) /
          totalTests;

      return {
        'totalTests': totalTests,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'totalTimeSpent': totalTimeSpent,
        'averageAccuracy': averageAccuracy,
        'histories': histories,
      };
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      return {};
    }
  }

  /// Stream test histories for real-time updates
  static Stream<List<TestHistory>> streamTestHistoryByUser(String userId) {
    return _firestore
        .collection(_testHistoryCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TestHistory.fromMap(doc.data()))
              .toList(),
        );
  }
}
