// lib/data/repositories/flashcard_progress_repository_impl.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/flashcard_progress.dart';
import '../../domain/repository_interfaces/flashcard_progress_repository.dart';
import '../models/flashcard_progress_model.dart';

class FlashcardProgressRepositoryImpl implements FlashcardProgressRepository {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  static const String _collectionName = 'flashcard_progress';
  static const String _localKeyPrefix = 'flashcard_progress_';

  FlashcardProgressRepositoryImpl({
    required FirebaseFirestore firestore,
    required SharedPreferences prefs,
  }) : _firestore = firestore,
       _prefs = prefs;

  String _getDocumentId(String userId, String topicId) => '${userId}_$topicId';
  String _getLocalKey(String userId, String topicId) =>
      '$_localKeyPrefix${userId}_$topicId';

  @override
  Future<FlashcardProgress?> getProgress({
    required String userId,
    required String topicId,
  }) async {
    try {
      // 1. Try to get from local storage first (faster)
      final localProgress = await _getLocalProgress(userId, topicId);
      if (localProgress != null) {
        // Start background sync from Firestore (non-blocking)
        _syncFromFirestore(userId, topicId);
        return localProgress;
      }

      // 2. If not in local, fetch from Firestore
      final firestoreProgress = await _getFirestoreProgress(userId, topicId);
      if (firestoreProgress != null) {
        // Save to local for next time
        final model = FlashcardProgressModel.fromEntity(firestoreProgress);
        await _saveLocal(model);
        return firestoreProgress;
      }

      // 3. No progress found
      return null;
    } catch (e) {
      print('Error getting progress: $e');
      // On error, try local only
      return await _getLocalProgress(userId, topicId);
    }
  }

  @override
  Future<void> saveProgress(FlashcardProgress progress) async {
    final model = FlashcardProgressModel.fromEntity(progress);

    print('💾 [Repository] Saving progress...');
    print('   Document ID: ${model.id}');
    print('   Mastered: ${model.masteredCardIds.length} cards');
    print('   Learning: ${model.learningCardIds.length} cards');

    // 1. Save to local first (fast, works offline)
    await _saveLocal(model);
    print('✅ [Repository] Saved to local storage');

    // 2. Try to sync to Firestore (can fail if offline)
    try {
      await _saveFirestore(model);
      print('✅ [Repository] Synced to Firestore successfully!');
    } catch (e) {
      print('❌ [Repository] Failed to sync to Firestore: $e');
      print('⚠️ [Repository] Data is safe in local storage, will retry later');
      // Data is safe in local storage, will sync later
    }
  }

  @override
  Future<void> updateCardProgress({
    required String userId,
    required String topicId,
    required List<String> masteredCardIds,
    required List<String> learningCardIds,
  }) async {
    // Get existing progress or create new
    final existing = await getProgress(userId: userId, topicId: topicId);
    final now = DateTime.now();

    final updated =
        existing?.copyWith(
          masteredCardIds: masteredCardIds,
          learningCardIds: learningCardIds,
          lastStudiedAt: now,
          updatedAt: now,
        ) ??
        FlashcardProgress.empty(
          userId: userId,
          topicId: topicId,
          allCardIds: [...masteredCardIds, ...learningCardIds],
        ).copyWith(
          masteredCardIds: masteredCardIds,
          learningCardIds: learningCardIds,
        );

    await saveProgress(updated);
  }

  @override
  Future<void> resetProgress({
    required String userId,
    required String topicId,
  }) async {
    // Create empty progress (all cards become learning cards)
    final emptyProgress = FlashcardProgress.empty(
      userId: userId,
      topicId: topicId,
      allCardIds: [], // Will be set during first study session
    );

    await saveProgress(emptyProgress);
  }

  @override
  Future<void> syncToFirestore() async {
    try {
      // Get all local keys
      final keys = _prefs.getKeys().where(
        (key) => key.startsWith(_localKeyPrefix),
      );

      for (final key in keys) {
        final jsonStr = _prefs.getString(key);
        if (jsonStr != null) {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          final model = FlashcardProgressModel.fromJson(json);
          await _saveFirestore(model);
        }
      }
    } catch (e) {
      print('Error syncing to Firestore: $e');
    }
  }

  @override
  Future<bool> hasLocalData({
    required String userId,
    required String topicId,
  }) async {
    final key = _getLocalKey(userId, topicId);
    return _prefs.containsKey(key);
  }

  // Private helper methods

  Future<FlashcardProgress?> _getLocalProgress(
    String userId,
    String topicId,
  ) async {
    try {
      final key = _getLocalKey(userId, topicId);
      final jsonStr = _prefs.getString(key);
      if (jsonStr == null) return null;

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return FlashcardProgressModel.fromJson(json);
    } catch (e) {
      print('Error reading local progress: $e');
      return null;
    }
  }

  Future<FlashcardProgress?> _getFirestoreProgress(
    String userId,
    String topicId,
  ) async {
    try {
      final docId = _getDocumentId(userId, topicId);
      final doc = await _firestore.collection(_collectionName).doc(docId).get();

      if (!doc.exists) return null;
      return FlashcardProgressModel.fromFirestore(doc);
    } catch (e) {
      print('Error reading Firestore progress: $e');
      return null;
    }
  }

  Future<void> _saveLocal(FlashcardProgressModel model) async {
    try {
      final key = _getLocalKey(model.userId, model.topicId);
      final jsonStr = jsonEncode(model.toJson());
      await _prefs.setString(key, jsonStr);
    } catch (e) {
      print('Error saving local progress: $e');
    }
  }

  Future<void> _saveFirestore(FlashcardProgressModel model) async {
    final docId = _getDocumentId(model.userId, model.topicId);

    print('🔥 [Firestore] Writing to collection: $_collectionName');
    print('🔥 [Firestore] Document ID: $docId');
    print('🔥 [Firestore] Project: engoapp-91373');

    await _firestore
        .collection(_collectionName)
        .doc(docId)
        .set(model.toFirestore());

    print('✅ [Firestore] Write successful!');
  }

  Future<void> _syncFromFirestore(String userId, String topicId) async {
    try {
      final firestoreProgress = await _getFirestoreProgress(userId, topicId);
      if (firestoreProgress != null) {
        final model = FlashcardProgressModel.fromEntity(firestoreProgress);
        await _saveLocal(model);
      }
    } catch (e) {
      print('Background sync failed: $e');
    }
  }
}
