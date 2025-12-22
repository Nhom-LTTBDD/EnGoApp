// lib/data/datasources/auth_local_datasource.dart
// Local datasource cho Auth - Xử lý lưu trữ local (token, user info)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failure.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// Lưu token
  Future<void> saveToken(String token);

  /// Lấy token
  Future<String?> getToken();

  /// Xóa token
  Future<void> deleteToken();

  /// Lưu thông tin user
  Future<void> saveUser(UserModel user);

  /// Lấy thông tin user
  Future<UserModel?> getUser();

  /// Xóa thông tin user
  Future<void> deleteUser();

  /// Xóa tất cả dữ liệu
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(_tokenKey, token);
    } catch (e) {
      throw const CacheFailure('Không thể lưu token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(_tokenKey);
    } catch (e) {
      throw const CacheFailure('Không thể đọc token');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await sharedPreferences.remove(_tokenKey);
    } catch (e) {
      throw const CacheFailure('Không thể xóa token');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await sharedPreferences.setString(_userKey, userJson);
    } catch (e) {
      throw const CacheFailure('Không thể lưu thông tin người dùng');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = sharedPreferences.getString(_userKey);
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw const CacheFailure('Không thể đọc thông tin người dùng');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await sharedPreferences.remove(_userKey);
    } catch (e) {
      throw const CacheFailure('Không thể xóa thông tin người dùng');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await Future.wait([deleteToken(), deleteUser()]);
    } catch (e) {
      throw const CacheFailure('Không thể xóa dữ liệu');
    }
  }
}
