// lib/data/datasources/auth_remote_datasource.dart
// Remote datasource cho Auth - Xử lý API calls

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/error/failure.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Đăng nhập qua API
  Future<AuthResultModel> login({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới qua API
  Future<AuthResultModel> register({
    required String email,
    required String password,
    required String name,
    String? birthDate,
  });

  /// Đăng xuất qua API
  Future<bool> logout(String token);

  /// Gửi OTP qua email
  Future<bool> forgotPassword(String email);

  /// Xác thực OTP
  Future<bool> verifyOTP({required String email, required String otp});

  /// Đặt lại mật khẩu
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  });

  /// Lấy thông tin user từ server
  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://api.engo.com', // Thay đổi theo API thực tế
  });

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResultModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw const AuthFailure('Email hoặc mật khẩu không đúng');
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<AuthResultModel> register({
    required String email,
    required String password,
    required String name,
    String? birthDate,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'birthDate': birthDate,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AuthResultModel.fromJson(data);
      } else if (response.statusCode == 409) {
        throw const ValidationFailure('Email đã được sử dụng');
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<bool> logout(String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw const NotFoundFailure('Email không tồn tại');
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<bool> verifyOTP({required String email, required String otp}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        throw const ValidationFailure('Mã OTP không đúng hoặc đã hết hạn');
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw const AuthFailure('Token không hợp lệ');
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }
}
