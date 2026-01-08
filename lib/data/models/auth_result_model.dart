// lib/data/models/auth_result_model.dart
// Model cho AuthResult với JSON serialization

import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

class AuthResultModel extends AuthResult {
  const AuthResultModel({required super.user, required super.token});

  /// Tạo AuthResultModel từ JSON
  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  /// Chuyển AuthResultModel sang JSON
  Map<String, dynamic> toJson() {
    return {'user': (user as UserModel).toJson(), 'token': token};
  }

  /// Tạo AuthResultModel từ Entity
  factory AuthResultModel.fromEntity(AuthResult authResult) {
    return AuthResultModel(
      user: UserModel.fromEntity(authResult.user),
      token: authResult.token,
    );
  }
}
