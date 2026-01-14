// lib/domain/entities/user.dart
// Entity đại diện cho người dùng trong hệ thống

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? birthDate;
  final String? avatarUrl;
  final String? avatarColor; // Màu avatar tùy chỉnh (null = auto)

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.birthDate,
    this.avatarUrl,
    this.avatarColor,
  });

  /// Copy với các giá trị mới
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? birthDate,
    String? avatarUrl,
    String? avatarColor,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    birthDate,
    avatarUrl,
    avatarColor,
  ];
}
