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

      _streak = await _streakService.getStreak(_userId);

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
}
