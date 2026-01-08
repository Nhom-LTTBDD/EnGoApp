// lib/data/models/user_model.dart
// Model cho User với JSON serialization

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.birthDate,
    super.avatarUrl,
  });

  /// Tạo UserModel từ JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      birthDate: json['birthDate'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Chuyển UserModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'birthDate': birthDate,
      'avatarUrl': avatarUrl,
    };
  }

  /// Tạo UserModel từ Entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      birthDate: user.birthDate,
      avatarUrl: user.avatarUrl,
    );
  }

  /// Copy với các giá trị mới
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? birthDate,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
