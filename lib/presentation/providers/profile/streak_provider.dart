// lib/presentation/providers/streak_provider.dart

import 'package:flutter/foundation.dart';
import '../../../core/services/streak_service.dart';
import '../../../domain/entities/user_streak.dart';

/// Provider quản lý state của streak
class StreakProvider with ChangeNotifier {
  final StreakService _streakService;

  // Current user ID
  String _userId = 'default_user';

  // Streak data
  UserStreak? _streak;

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _error;

  // Streak break detection
  bool _hasStreakBroken = false;
  int _previousStreak = 0;
  bool _hasShownBreakNotification = false;

  StreakProvider({required StreakService streakService})
    : _streakService = streakService;
  // Note: Streak will be loaded lazily when setUserId is called

  // Getters
  UserStreak? get streak => _streak;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStreak => _streak?.currentStreak ?? 0;
  int get longestStreak => _streak?.longestStreak ?? 0;
  DateTime? get lastActivityDate => _streak?.lastActivityDate;
  bool get hasStreakBroken => _hasStreakBroken;
  int get previousStreak => _previousStreak;
  bool get hasShownBreakNotification => _hasShownBreakNotification;

  /// Set user ID và reload streak
  void setUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      loadStreak();
    }
    // Remove duplicate load - only load when userId changes
  }

  /// Load streak từ service
  Future<void> loadStreak() async {
    // Prevent concurrent loads
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get previous streak before loading new one
      final previousCurrentStreak = _streak?.currentStreak ?? 0;

      _streak = await _streakService.getStreak(_userId);

      // Check if streak was broken (only on first load after app start)
      // Detect if: had previous streak > 1 AND now streak = 1 AND lastActivity was more than 1 day ago
      if (!_hasShownBreakNotification && previousCurrentStreak == 0) {
        // First time loading - check if streak should have been broken
        await _checkStreakBreak();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Record activity (gọi khi hoàn thành flashcard)
  /// Returns: Map with 'increased' (bool), 'oldStreak' (int), 'newStreak' (int)
  Future<Map<String, dynamic>> recordActivity() async {
    try {
      print('🎯 Recording activity for user: $_userId');

      final updatedStreak = await _streakService.recordActivity(_userId);

      // Check if streak increased
      final oldStreak = _streak?.currentStreak ?? 0;
      final newStreak = updatedStreak.currentStreak;

      _streak = updatedStreak;
      notifyListeners();

      final increased = newStreak > oldStreak;

      // Show celebration if streak increased
      if (increased) {
        print('🎉 Streak increased from $oldStreak to $newStreak!');
      } else if (newStreak == oldStreak && oldStreak > 0) {
        print('🔥 Streak maintained: $newStreak days');
      }

      return {
        'increased': increased,
        'oldStreak': oldStreak,
        'newStreak': newStreak,
      };
    } catch (e) {
      _error = e.toString();
      print('❌ Error recording activity: $e');
      notifyListeners();
      return {'increased': false, 'oldStreak': 0, 'newStreak': 0};
    }
  }

  /// Reset streak (for testing)
  Future<void> resetStreak() async {
    try {
      await _streakService.resetStreak(_userId);
      await loadStreak();
      print('🔄 Streak reset');
    } catch (e) {
      _error = e.toString();
      print('❌ Error resetting streak: $e');
      notifyListeners();
    }
  }

  /// Force sync to cloud
  Future<void> forceSyncToCloud() async {
    try {
      await _streakService.forceSyncToCloud(_userId);
      print('☁️ Streak synced to cloud');
    } catch (e) {
      _error = e.toString();
      print('❌ Error syncing to cloud: $e');
    }
  }

  /// Clear local streak (when user logs out)
  Future<void> clearLocalStreak() async {
    try {
      await _streakService.clearLocalStreak(_userId);
      _streak = null;
      notifyListeners();
      print('🗑️ Local streak cleared');
    } catch (e) {
      _error = e.toString();
      print('❌ Error clearing local streak: $e');
    }
  }

  /// Check if streak was broken (runs in background, non-blocking)
  Future<void> _checkStreakBreak() async {
    if (_streak == null || _streak!.lastActivityDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      _streak!.lastActivityDate!.year,
      _streak!.lastActivityDate!.month,
      _streak!.lastActivityDate!.day,
    );

    final daysSinceLastActivity = today.difference(lastDate).inDays;

    // Streak broken if: missed 1+ days AND had previous streak > 1 AND current = 1
    if (daysSinceLastActivity > 1 &&
        _streak!.longestStreak > 1 &&
        _streak!.currentStreak == 1) {
      _hasStreakBroken = true;
      _previousStreak = _streak!.longestStreak;
      print('💔 Detected streak break: Lost ${_previousStreak - 1} day streak');
    }
  }

  /// Mark break notification as shown
  void markBreakNotificationShown() {
    _hasShownBreakNotification = true;
    _hasStreakBroken = false; // Reset flag after showing
    notifyListeners();
  }
}
