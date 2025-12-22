// lib/data/datasources/profile_local_datasource.dart
// Local datasource cho Profile - Xử lý cache profile

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/failure.dart';
import '../../models/user_model.dart';

abstract class ProfileLocalDataSource {
  /// Lưu profile vào cache
  Future<void> cacheProfile(UserModel profile);

  /// Lấy profile từ cache
  Future<UserModel?> getCachedProfile();

  /// Xóa profile cache
  Future<void> clearProfileCache();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _profileCacheKey = 'profile_cache';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProfile(UserModel profile) async {
    try {
      final profileJson = jsonEncode(profile.toJson());
      await sharedPreferences.setString(_profileCacheKey, profileJson);
    } catch (e) {
      throw const CacheFailure('Không thể lưu profile');
    }
  }

  @override
  Future<UserModel?> getCachedProfile() async {
    try {
      final profileJson = sharedPreferences.getString(_profileCacheKey);
      if (profileJson == null) return null;

      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserModel.fromJson(profileMap);
    } catch (e) {
      throw const CacheFailure('Không thể đọc profile từ cache');
    }
  }

  @override
  Future<void> clearProfileCache() async {
    try {
      await sharedPreferences.remove(_profileCacheKey);
    } catch (e) {
      throw const CacheFailure('Không thể xóa profile cache');
    }
  }
}
