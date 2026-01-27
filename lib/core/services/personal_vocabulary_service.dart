// lib/core/services/personal_vocabulary_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../data/models/personal_vocabulary_model.dart';
import '../constants/vocabulary_constants.dart';

// Top-level functions for JSON parsing in isolates
Map<String, dynamic>? _parseJsonFromString(String? jsonString) {
  if (jsonString == null) return null;
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

String _encodeJsonToString(Map<String, dynamic> json) {
  return jsonEncode(json);
}

/// Service quản lý từ vựng cá nhân với chiến lược Hybrid Storage.
///
/// **Architecture:**
/// - Local-first: SharedPreferences cho truy cập nhanh offline
/// - Cloud sync: Firestore cho backup và multi-device sync
/// - Debouncing: Tối ưu Firestore writes
///
/// **Thread-safe:** Service này không thread-safe, nên sử dụng từ main thread.
class PersonalVocabularyService {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  DateTime? _lastSyncTime;

  // Constants
  static const String _storageKey =
      VocabularyConstants.personalVocabularyStorageKey;
  static const String _firestoreCollection =
      VocabularyConstants.personalVocabulariesCollection;
  static const Duration _syncInterval =
      VocabularyConstants.syncDebounceInterval;

  PersonalVocabularyService(this._prefs, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;  // ============================================================================
  // Public API - Read Operations
  // ============================================================================
  
  /// Lấy personal vocabulary với fallback strategy: Local → Cloud → Empty
  /// 
  /// **Strategy:**
  /// 1. Đọc từ SharedPreferences (nhanh nhất, offline-first)
  /// 2. Nếu không có local, fallback lên Firestore (slower, requires internet)
  /// 3. Nếu cả 2 đều fail, trả về empty model
  /// 
  /// **Tham số:** userId - ID của user cần load vocabulary
  /// **Trả về:** PersonalVocabularyModel chứa list card IDs đã bookmark
  Future<PersonalVocabularyModel> getPersonalVocabulary(String userId) async {
    try {
      _logInfo('🔍 getPersonalVocabulary called for userId: $userId');

      // Strategy 1: Đọc từ local storage (fastest)
      final localModel = await _loadFromLocal();
      if (localModel != null && localModel.userId == userId) {
        _logInfo(
          '${VocabularyConstants.logLoadingFromLocal}: ${localModel.vocabularyCardIds.length} cards',
        );
        return localModel;
      }

      // Strategy 2: Fallback to cloud
      _logInfo(VocabularyConstants.logLoadingFromCloud);
      final cloudModel = await _loadFromCloud(userId);
      if (cloudModel != null) {
        _logInfo(
          '☁️ Cloud model found: ${cloudModel.vocabularyCardIds.length} cards',
        );
        _logInfo(
          '📋 Card IDs from cloud: ${cloudModel.vocabularyCardIds.join(", ")}',
        );
        await _saveToLocal(cloudModel);
        _logInfo(
          '${VocabularyConstants.logRestoredFromCloud}: ${cloudModel.vocabularyCardIds.length} cards',
        );
        return cloudModel;
      }

      // Strategy 3: Return empty model
      _logInfo(VocabularyConstants.logNoDataFound);
      return PersonalVocabularyModel.empty(userId);
    } catch (e) {
      _logError('${VocabularyConstants.errorLoadingVocabulary}: $e');
      return PersonalVocabularyModel.empty(userId);
    }
  }
  // ============================================================================
  // SAVE - Hybrid: Local + Cloud
  // ============================================================================
  
  /// Lưu personal vocabulary vào cả local và cloud
  /// 
  /// **Flow:**
  /// 1. Lưu ngay vào SharedPreferences (đảm bảo không mất data)
  /// 2. Sync lên Firestore (async, với debouncing 5s)
  /// 
  /// **Tham số:** model - PersonalVocabularyModel cần lưu
  /// **Lưu ý:** Không block UI, Firestore sync chạy background
  Future<void> savePersonalVocabulary(PersonalVocabularyModel model) async {
    try {
      // 1. Lưu vào local storage (always, synchronous)
      await _saveToLocal(model);

      // 2. Sync lên cloud (with debouncing)
      _syncToCloud(model);
    } catch (e) {
      _logError('${VocabularyConstants.errorSavingVocabulary}: $e');
      rethrow;
    }
  }

  // ============================================================================
  // OPERATIONS - Add/Remove/Toggle
  // ============================================================================

  /// Thêm card vào personal vocabulary
  Future<void> addCard(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    final updated = model.addCard(cardId);
    await savePersonalVocabulary(updated);
  }

  /// Xóa card khỏi personal vocabulary
  Future<void> removeCard(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    final updated = model.removeCard(cardId);
    await savePersonalVocabulary(updated);
  }

  /// Toggle bookmark (thêm nếu chưa có, xóa nếu đã có)
  Future<bool> toggleBookmark(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    final updated = model.toggleBookmark(cardId);
    await savePersonalVocabulary(updated);
    return updated.isBookmarked(cardId);
  }

  /// Kiểm tra card đã được bookmark chưa
  Future<bool> isBookmarked(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    return model.isBookmarked(cardId);
  }

  /// Lấy danh sách tất cả card IDs đã bookmark
  Future<List<String>> getBookmarkedCardIds(String userId) async {
    final model = await getPersonalVocabulary(userId);
    return model.vocabularyCardIds;
  }

  /// Force load từ cloud và save vào local (dùng khi sync hoặc refresh)
  Future<PersonalVocabularyModel> forceLoadFromCloud(String userId) async {
    try {
      print(
        '[PERSONAL_VOCAB_SERVICE] Force loading from cloud for user: $userId',
      );
      final cloudModel = await _loadFromCloud(userId);

      if (cloudModel != null) {
        await _saveToLocal(cloudModel);
        print(
          '[PERSONAL_VOCAB_SERVICE] Force loaded from cloud: ${cloudModel.vocabularyCardIds.length} cards',
        );
        return cloudModel;
      }

      return PersonalVocabularyModel.empty(userId);
    } catch (e) {
      print('[PERSONAL_VOCAB_SERVICE] Error force loading from cloud: $e');
      return PersonalVocabularyModel.empty(userId);
    }
  }

  /// Xóa tất cả bookmarks
  Future<void> clearAll(String userId) async {
    final model = PersonalVocabularyModel.empty(userId);
    await savePersonalVocabulary(model);
  }

  // ============================================================================
  // PRIVATE HELPERS - Local Storage
  // ============================================================================
  Future<void> _saveToLocal(PersonalVocabularyModel model) async {
    try {
      // Encode JSON in isolate to avoid blocking main thread
      final jsonString = await compute(_encodeJsonToString, model.toJson());
      await _prefs.setString(_storageKey, jsonString);
      _logInfo(VocabularyConstants.logSavedToLocal);
    } catch (e) {
      _logError('${VocabularyConstants.errorSavingToLocal}: $e');
      rethrow;
    }
  }

  // ============================================================================
  // PRIVATE HELPERS - Cloud Storage (Firestore)
  // ============================================================================
  /// Load từ Firestore
  Future<PersonalVocabularyModel?> _loadFromCloud(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .get()
          .timeout(VocabularyConstants.cloudLoadTimeout);

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        _logInfo('No cloud data found for user: $userId');
        return null;
      }

      final data = docSnapshot.data()!;
      return PersonalVocabularyModel.fromJson(data);
    } catch (e) {
      _logError('${VocabularyConstants.errorLoadingFromCloud}: $e');
      return null;
    }
  }

  /// Sync lên Firestore với debouncing
  void _syncToCloud(PersonalVocabularyModel model) {
    _logInfo('_syncToCloud called for user: ${model.userId}');

    // Debouncing: Chỉ sync nếu đã qua 5 giây kể từ lần sync cuối
    final now = DateTime.now();
    if (_lastSyncTime != null) {
      final timeSinceLastSync = now.difference(_lastSyncTime!);
      _logInfo('Time since last sync: ${timeSinceLastSync.inSeconds}s');

      if (timeSinceLastSync < _syncInterval) {
        _logInfo(
          '${VocabularyConstants.logSyncSkipped} - wait ${_syncInterval.inSeconds - timeSinceLastSync.inSeconds}s more)',
        );
        return;
      }
    }

    _lastSyncTime = now;
    _logInfo(VocabularyConstants.logStartingSync);

    // Fire-and-forget: Không await, không block UI
    _firestore
        .collection(_firestoreCollection)
        .doc(model.userId)
        .set(model.toJson(), SetOptions(merge: true))
        .then((_) {
          _logInfo(
            '${VocabularyConstants.logSyncedToCloud}: ${model.vocabularyCardIds.length} cards',
          );
        })
        .catchError((e) {
          _logError('${VocabularyConstants.logSyncFailed}: $e');
          _logError(' Error type: ${e.runtimeType}');
          _logError(' Error details: ${e.toString()}');
        });
  }

  // ============================================================================
  // UTILITIES - Force Sync
  // ============================================================================
  /// Force sync ngay lập tức (không debouncing)
  /// Dùng khi logout hoặc cần chắc chắn data đã được save
  Future<void> forceSyncToCloud(String userId) async {
    try {
      final model = await getPersonalVocabulary(userId);

      await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .set(model.toJson(), SetOptions(merge: true))
          .timeout(VocabularyConstants.forceSyncTimeout);

      _logInfo(
        ' Force synced to cloud: ${model.vocabularyCardIds.length} cards',
      );
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _logError('${VocabularyConstants.errorForceSyncFailed}: $e');
      rethrow;
    }
  }

  /// Restore từ cloud về local (dùng khi cài lại app)
  Future<void> restoreFromCloud(String userId) async {
    try {
      final cloudModel = await _loadFromCloud(userId);

      if (cloudModel != null) {
        await _saveToLocal(cloudModel);
        _logInfo(' Restored from cloud to local');
      } else {
        _logInfo(' No cloud data to restore');
      }
    } catch (e) {
      _logError('${VocabularyConstants.errorRestoreFailed}: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS - Load from Local
  // ============================================================================

  /// Load từ SharedPreferences
  Future<PersonalVocabularyModel?> _loadFromLocal() async {
    try {
      final jsonString = _prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      // Parse JSON in isolate to avoid blocking main thread
      final jsonMap = await compute(_parseJsonFromString, jsonString);
      if (jsonMap == null) return null;

      return PersonalVocabularyModel.fromJson(jsonMap);
    } catch (e) {
      _logError('${VocabularyConstants.errorSavingToLocal}: $e');
      return null;
    }
  } // ============================================================================
  // LOGGING HELPERS
  // ============================================================================

  void _logInfo(String message) {
    print('[PERSONAL_VOCAB_SERVICE] $message');
  }

  void _logWarning(String message) {
    print('[PERSONAL_VOCAB_SERVICE] $message');
  }

  void _logError(String message) {
    print('[PERSONAL_VOCAB_SERVICE] $message');
  }
}
