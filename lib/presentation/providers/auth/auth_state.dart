// lib/presentation/providers/auth/auth_state.dart
// Các trạng thái của Auth

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// Base Auth State
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class AuthInitial extends AuthState {}

/// Đang xử lý
class AuthLoading extends AuthState {}

/// Đã xác thực
class Authenticated extends AuthState {
  final User user;

  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Chưa xác thực
class Unauthenticated extends AuthState {}

/// Lỗi
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Đã gửi OTP
class OTPSent extends AuthState {
  final String email;

  OTPSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// OTP đã xác thực
class OTPVerified extends AuthState {
  final String email;

  OTPVerified(this.email);

  @override
  List<Object?> get props => [email];
}

/// Mật khẩu đã được reset
class PasswordReset extends AuthState {}
