// lib/core/services/streak_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../domain/entities/user_streak.dart';

/// Service quản lý streak với Hybrid Storage (Local + Firebase)
class StreakService {
  static const String _storageKey = 'user_streak';
  static const String _firestoreCollection = 'user_streaks';

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  StreakService(this._prefs, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================================
  // GET Streak
  // ============================================================================

  /// Lấy streak từ local, fallback to cloud nếu không có
  Future<UserStreak> getStreak(String userId) async {
    try {
      // 1. Đọc từ local storage
      final jsonString = _prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final streak = UserStreak.fromJson(json);

        if (streak.userId == userId) {
          print('✅ Loaded streak from local: ${streak.currentStreak} days');
          return streak;
        }
      }

      // 2. Local empty → load from cloud
      print('📡 Loading streak from cloud...');
      final cloudStreak = await _loadFromCloud(userId);

      if (cloudStreak != null) {
        await _saveToLocal(cloudStreak);
        print(
          '✅ Restored streak from cloud: ${cloudStreak.currentStreak} days',
        );
        return cloudStreak;
      }

      // 3. Không có data → tạo mới và lưu vào cả local và cloud
      print('📝 Creating new streak for user');
      final newStreak = UserStreak.initial(userId);
      await _saveStreak(newStreak);
      print('✅ New streak created and saved to local + cloud');
      return newStreak;
    } catch (e) {
      print('⚠️ Error loading streak: $e');
      return UserStreak.initial(userId);
    }
  }

  // ============================================================================
  // UPDATE Streak - Logic chính
  // ============================================================================

  /// Record activity (gọi khi hoàn thành flashcard)
  Future<UserStreak> recordActivity(String userId) async {
    try {
      final currentStreak = await getStreak(userId);
      final updatedStreak = _calculateNewStreak(currentStreak);

      await _saveStreak(updatedStreak);

      print('🔥 Streak updated: ${updatedStreak.currentStreak} days');
      return updatedStreak;
    } catch (e) {
      print('⚠️ Error recording activity: $e');
      rethrow;
    }
  }

  /// Tính toán streak mới dựa vào logic ngày
  UserStreak _calculateNewStreak(UserStreak current) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Chưa có activity trước đó
    if (current.lastActivityDate == null) {
      return current.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastActivityDate: today,
        updatedAt: now,
      );
    }

    final lastDate = DateTime(
      current.lastActivityDate!.year,
      current.lastActivityDate!.month,
      current.lastActivityDate!.day,
    );

    final daysDiff = today.difference(lastDate).inDays;

    if (daysDiff == 0) {
      // Cùng ngày → không thay đổi streak
      print('⏭️ Already counted today');
      return current;
    } else if (daysDiff == 1) {
      // Ngày tiếp theo → tăng streak
      final newStreak = current.currentStreak + 1;
      final newLongest = newStreak > current.longestStreak
          ? newStreak
          : current.longestStreak;

      print('⬆️ Streak increased to $newStreak days');
      return current.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActivityDate: today,
        updatedAt: now,
      );
    } else {
      // Bỏ lỡ ngày → reset về 1
      print('💔 Streak broken! Resetting to 1');
      return current.copyWith(
        currentStreak: 1,
        lastActivityDate: today,
        updatedAt: now,
      );
    }
  }

  // ============================================================================
  // SAVE Streak
  // ============================================================================

  /// Lưu streak vào cả local và cloud
  Future<void> _saveStreak(UserStreak streak) async {
    await _saveToLocal(streak);
    _syncToCloud(streak); // Fire-and-forget
  }

  Future<void> _saveToLocal(UserStreak streak) async {
    try {
      final jsonString = jsonEncode(streak.toJson());
      await _prefs.setString(_storageKey, jsonString);
      print('💾 Saved streak to local');
    } catch (e) {
      print('⚠️ Error saving to local: $e');
      rethrow;
    }
  }

  void _syncToCloud(UserStreak streak) {
    _firestore
        .collection(_firestoreCollection)
        .doc(streak.userId)
        .set(streak.toJson(), SetOptions(merge: true))
        .then((_) {
          print('☁️ Synced streak to cloud');
        })
        .catchError((e) {
          print('⚠️ Cloud sync failed: $e');
        });
  }

  // ============================================================================
  // LOAD from Cloud
  // ============================================================================

  Future<UserStreak?> _loadFromCloud(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 5));

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }

      return UserStreak.fromJson(docSnapshot.data()!);
    } catch (e) {
      print('⚠️ Error loading from cloud: $e');
      return null;
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Force sync to cloud
  Future<void> forceSyncToCloud(String userId) async {
    try {
      final streak = await getStreak(userId);
      await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .set(streak.toJson(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));

      print('✅ Force synced streak to cloud');
    } catch (e) {
      print('⚠️ Force sync failed: $e');
      rethrow;
    }
  }

  /// Reset streak (for testing/admin)
  Future<void> resetStreak(String userId) async {
    final resetStreak = UserStreak.initial(userId);
    await _saveStreak(resetStreak);
    print('🔄 Streak reset to 0');
  }
}
