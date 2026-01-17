// lib/core/services/personal_vocabulary_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../data/models/personal_vocabulary_model.dart';

/// Service quản lý từ vựng cá nhân với chiến lược Hybrid Storage:
/// 
/// **Local Storage (SharedPreferences):**
/// - Lưu trữ offline, truy cập nhanh
/// - Hoạt động ngay cả khi không có mạng
/// 
/// **Cloud Storage (Firestore):**
/// - Backup tự động lên cloud
/// - Restore khi cài lại app hoặc đăng nhập từ thiết bị khác
/// - Đảm bảo không mất dữ liệu khi clear app data
/// 
/// **Sync Strategy:**
/// - Read: Local-first, fallback to cloud nếu local empty
/// - Write: Local + Cloud (fire-and-forget)
/// - Debouncing: Tránh sync quá nhiều lần (min 5s interval)
class PersonalVocabularyService {
  static const String _storageKey = 'personal_vocabulary';
  static const String _firestoreCollection = 'personal_vocabularies';
    final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  
  /// Last sync timestamp để tránh sync quá thường xuyên
  DateTime? _lastSyncTime;
  static const _syncInterval = Duration(seconds: 5);

  PersonalVocabularyService(
    this._prefs, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================================
  // GET - Local-first với fallback to Cloud
  // ============================================================================
  
  /// Lấy personal vocabulary từ local, nếu empty thì load từ cloud
  Future<PersonalVocabularyModel> getPersonalVocabulary(String userId) async {
    try {
      // 1. Đọc từ local storage trước (fast)
      final jsonString = _prefs.getString(_storageKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final model = PersonalVocabularyModel.fromJson(json);
        
        // Verify userId matches
        if (model.userId == userId) {
          print('✅ Loaded from local storage: ${model.vocabularyCardIds.length} cards');
          return model;
        }
      }

      // 2. Local empty hoặc wrong user → load from cloud
      print('📡 Local storage empty, fetching from cloud...');
      final cloudModel = await _loadFromCloud(userId);
      
      if (cloudModel != null) {
        // Lưu vào local để lần sau dùng
        await _saveToLocal(cloudModel);
        print('✅ Restored from cloud: ${cloudModel.vocabularyCardIds.length} cards');
        return cloudModel;
      }

      // 3. Cloud cũng empty → return empty model
      print('📝 No data found, creating new empty model');
      return PersonalVocabularyModel.empty(userId);
      
    } catch (e) {
      print('⚠️ Error loading personal vocabulary: $e');
      return PersonalVocabularyModel.empty(userId);
    }
  }

  // ============================================================================
  // SAVE - Hybrid: Local + Cloud
  // ============================================================================
  
  /// Lưu personal vocabulary vào cả local và cloud
  Future<void> savePersonalVocabulary(PersonalVocabularyModel model) async {
    try {
      // 1. Lưu vào local storage (always, synchronous)
      await _saveToLocal(model);
      
      // 2. Sync lên cloud (with debouncing)
      _syncToCloud(model);
      
    } catch (e) {
      print('⚠️ Error saving personal vocabulary: $e');
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
      final jsonString = jsonEncode(model.toJson());
      await _prefs.setString(_storageKey, jsonString);
      print('💾 Saved to local storage');
    } catch (e) {
      print('⚠️ Error saving to local: $e');
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
          .timeout(const Duration(seconds: 5));

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        print('📭 No cloud data found for user: $userId');
        return null;
      }

      final data = docSnapshot.data()!;
      return PersonalVocabularyModel.fromJson(data);
      
    } catch (e) {
      print('⚠️ Error loading from cloud: $e');
      return null;
    }
  }

  /// Sync lên Firestore với debouncing
  void _syncToCloud(PersonalVocabularyModel model) {
    // Debouncing: Chỉ sync nếu đã qua 5 giây kể từ lần sync cuối
    final now = DateTime.now();
    if (_lastSyncTime != null && 
        now.difference(_lastSyncTime!) < _syncInterval) {
      print('⏭️ Skipping cloud sync (debouncing)');
      return;
    }

    _lastSyncTime = now;

    // Fire-and-forget: Không await, không block UI
    _firestore
        .collection(_firestoreCollection)
        .doc(model.userId)
        .set(model.toJson(), SetOptions(merge: true))
        .then((_) {
          print('☁️ Synced to cloud: ${model.vocabularyCardIds.length} cards');
        })
        .catchError((e) {
          print('⚠️ Cloud sync failed: $e');
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
          .timeout(const Duration(seconds: 10));
      
      print('✅ Force synced to cloud: ${model.vocabularyCardIds.length} cards');
      _lastSyncTime = DateTime.now();
      
    } catch (e) {
      print('⚠️ Force sync failed: $e');
      rethrow;
    }
  }

  /// Restore từ cloud về local (dùng khi cài lại app)
  Future<void> restoreFromCloud(String userId) async {
    try {
      final cloudModel = await _loadFromCloud(userId);
      
      if (cloudModel != null) {
        await _saveToLocal(cloudModel);
        print('✅ Restored from cloud to local');
      } else {
        print('📭 No cloud data to restore');
      }
    } catch (e) {
      print('⚠️ Restore failed: $e');
    }
  }
}
