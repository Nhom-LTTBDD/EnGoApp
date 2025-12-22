// lib/data/datasources/profile_remote_datasource.dart
// Remote datasource cho Profile - Xử lý API calls

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/error/failure.dart';
import '../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  /// Lấy thông tin profile từ server
  Future<UserModel> getUserProfile(String token);

  /// Cập nhật thông tin profile
  Future<UserModel> updateProfile({
    required String token,
    required String name,
    String? birthDate,
  });

  /// Upload và cập nhật avatar
  Future<String> updateAvatar({
    required String token,
    required String imagePath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ProfileRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://api.engo.com', // Thay đổi theo API thực tế
  });

  @override
  Future<UserModel> getUserProfile(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/profile'),
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

  @override
  Future<UserModel> updateProfile({
    required String token,
    required String name,
    String? birthDate,
  }) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'birthDate': birthDate}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw const AuthFailure('Token không hợp lệ');
      } else if (response.statusCode == 400) {
        throw const ValidationFailure('Dữ liệu không hợp lệ');
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<String> updateAvatar({
    required String token,
    required String imagePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/avatar'),
      );

      // Thêm headers
      request.headers['Authorization'] = 'Bearer $token';

      // Thêm file
      final file = await http.MultipartFile.fromPath('avatar', imagePath);
      request.files.add(file);

      // Gửi request
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['avatarUrl'] as String;
      } else if (response.statusCode == 401) {
        throw const AuthFailure('Token không hợp lệ');
      } else if (response.statusCode == 400) {
        throw const ValidationFailure('File không hợp lệ');
      } else {
        throw ServerFailure('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }
}
