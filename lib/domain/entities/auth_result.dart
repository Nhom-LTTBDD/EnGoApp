// lib/domain/entities/auth_result.dart
// Kết quả của quá trình xác thực

import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResult extends Equatable {
  final User user;

  const AuthResult({required this.user});

  @override
  List<Object> get props => [user];
}
