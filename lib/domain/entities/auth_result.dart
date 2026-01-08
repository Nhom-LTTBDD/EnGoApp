// lib/domain/entities/auth_result.dart
// Kết quả của quá trình xác thực

import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResult extends Equatable {
  final User user;
  final String token;

  const AuthResult({required this.user, required this.token});

  @override
  List<Object> get props => [user, token];
}
