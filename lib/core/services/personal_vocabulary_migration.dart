// lib/core/services/personal_vocabulary_migration.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'personal_vocabulary_service.dart';

/// Helper class để migrate existing users từ local-only sang hybrid storage
/// 
/// **Khi nào cần dùng:**
/// - Khi update app từ version cũ (chỉ có local storage)
/// - Lần đầu tiên user login sau khi update
/// 
/// **Cách dùng:**
/// ```dart
/// // Trong AuthProvider sau khi login thành công
/// await PersonalVocabularyMigration.migrateIfNeeded(
///   userId: user.id,
///   service: personalVocabularyService,
/// );
/// ```
class PersonalVocabularyMigration {
  static const String _migrationKey = 'personal_vocab_migrated_to_cloud';

  /// Check và migrate nếu chưa từng migrate
  static Future<bool> migrateIfNeeded({
    required String userId,
    required PersonalVocabularyService service,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasMigrated = prefs.getBool('$_migrationKey\_$userId') ?? false;

      if (hasMigrated) {
        print('User đã được migrate trước đó');
        return true;
      }

      print('Bắt đầu migration cho user: $userId');

      // 1. Load data local hiện tại
      final localModel = await service.getPersonalVocabulary(userId);

      if (localModel.vocabularyCardIds.isEmpty) {
        print('Không có data local để migrate');
        await _markAsMigrated(prefs, userId);
        return true;
      }

      // 2. Force sync lên cloud
      print('Syncing ${localModel.vocabularyCardIds.length} cards to cloud...');
      await service.forceSyncToCloud(userId);

      // 3. Đánh dấu đã migrate
      await _markAsMigrated(prefs, userId);

      print('Migration completed: ${localModel.vocabularyCardIds.length} cards');
      return true;

    } catch (e) {
      print('Migration failed: $e');
      return false;
    }
  }

  /// Force migrate lại (cho debugging)
  static Future<void> forceMigrate({
    required String userId,
    required PersonalVocabularyService service,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_migrationKey\_$userId');
    await migrateIfNeeded(userId: userId, service: service);
  }

  /// Reset migration flag (cho testing)
  static Future<void> resetMigrationFlag(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_migrationKey\_$userId');
    print('Reset migration flag for user: $userId');
  }

  /// Check xem user đã migrate chưa
  static Future<bool> hasMigrated(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_migrationKey\_$userId') ?? false;
  }

  static Future<void> _markAsMigrated(
    SharedPreferences prefs,
    String userId,
  ) async {
    await prefs.setBool('$_migrationKey\_$userId', true);
    print('Đã đánh dấu migration completed cho user: $userId');
  }
}
