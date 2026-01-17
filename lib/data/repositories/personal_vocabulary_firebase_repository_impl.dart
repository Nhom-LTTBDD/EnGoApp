// lib/data/repositories/personal_vocabulary_firebase_repository_impl.dart
// EXAMPLE - Firebase implementation cho PersonalVocabularyRepository

// CHƯA SỬ DỤNG - Đây là template cho việc implement Firebase sau này

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repository_interfaces/personal_vocabulary_repository.dart';

/// Firebase/Firestore implementation của PersonalVocabularyRepository
///
/// Firestore Structure:
/// ```
/// users/{userId}/personal_vocabulary/
///   └─ metadata (document)
///       ├─ vocabularyCardIds: [String]
///       ├─ createdAt: Timestamp
///       ├─ updatedAt: Timestamp
///       ├─ totalCount: int
///       └─ statsByTopic: Map<String, int>
/// ```
class PersonalVocabularyFirebaseRepositoryImpl
    implements PersonalVocabularyRepository {
  final FirebaseFirestore _firestore;

  PersonalVocabularyFirebaseRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  DocumentReference _getUserVocabDoc(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('personal_vocabulary')
        .doc('metadata');
  }

  @override
  Future<List<String>> getBookmarkedCardIds(String userId) async {
    try {
      final doc = await _getUserVocabDoc(userId).get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data() as Map<String, dynamic>?;
      return List<String>.from(data?['vocabularyCardIds'] ?? []);
    } catch (e) {
      print('Error getting bookmarked cards from Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<void> addCard(String userId, String cardId) async {
    try {
      await _getUserVocabDoc(userId).set({
        'vocabularyCardIds': FieldValue.arrayUnion([cardId]),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding card to Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeCard(String userId, String cardId) async {
    try {
      await _getUserVocabDoc(userId).update({
        'vocabularyCardIds': FieldValue.arrayRemove([cardId]),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error removing card from Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<bool> toggleBookmark(String userId, String cardId) async {
    try {
      final isCurrentlyBookmarked = await isBookmarked(userId, cardId);

      if (isCurrentlyBookmarked) {
        await removeCard(userId, cardId);
        return false;
      } else {
        await addCard(userId, cardId);
        return true;
      }
    } catch (e) {
      print('Error toggling bookmark in Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isBookmarked(String userId, String cardId) async {
    try {
      final cardIds = await getBookmarkedCardIds(userId);
      return cardIds.contains(cardId);
    } catch (e) {
      print('Error checking bookmark in Firestore: $e');
      return false;
    }
  }

  @override
  Future<void> clearAll(String userId) async {
    try {
      await _getUserVocabDoc(userId).set({
        'vocabularyCardIds': [],
        'updatedAt': FieldValue.serverTimestamp(),
        'totalCount': 0,
        'statsByTopic': {},
      });
    } catch (e) {
      print('Error clearing vocabulary in Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCardCount(String userId) async {
    try {
      final doc = await _getUserVocabDoc(userId).get();

      if (!doc.exists) {
        return 0;
      }

      final data = doc.data() as Map<String, dynamic>?;
      return data?['totalCount'] ?? 0;
    } catch (e) {
      print('Error getting card count from Firestore: $e');
      return 0;
    }
  }

  @override
  Future<Map<String, int>> getStatsByTopic(String userId) async {
    try {
      final doc = await _getUserVocabDoc(userId).get();

      if (!doc.exists) {
        return {};
      }

      final data = doc.data() as Map<String, dynamic>?;
      final statsData = data?['statsByTopic'] as Map<String, dynamic>?;

      if (statsData == null) {
        return {};
      }

      return statsData.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('Error getting stats from Firestore: $e');
      return {};
    }
  }

  @override
  Future<void> syncToRemote(String userId) async {
    // Already remote, no-op
  }

  @override
  Future<void> syncFromRemote(String userId) async {
    // Already remote, no-op
  }

  /// Update stats by topic (helper method)
  Future<void> updateTopicStats(
    String userId,
    String topicId,
    int delta,
  ) async {
    try {
      await _getUserVocabDoc(userId).update({
        'statsByTopic.$topicId': FieldValue.increment(delta),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating topic stats in Firestore: $e');
      rethrow;
    }
  }
}
