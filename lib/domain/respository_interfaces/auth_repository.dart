// lib/domain/respository_interfaces/auth_repository.dart
// Interface định nghĩa các phương thức liên quan đến xác thực

import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/auth_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Đăng nhập
  ///
  /// [email] - Email người dùng
  /// [password] - Mật khẩu
  /// Returns: AuthResult nếu thành công, Failure nếu thất bại
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới
  ///
  /// [email] - Email người dùng
  /// [password] - Mật khẩu
  /// [name] - Tên người dùng
  /// [birthDate] - Ngày sinh (optional)
  /// Returns: AuthResult nếu thành công, Failure nếu thất bại
  Future<Either<Failure, AuthResult>> register({
    required String email,
    required String password,
    required String name,
    String? birthDate,
  });

  /// Đăng xuất
  ///
  /// Returns: true nếu thành công, Failure nếu thất bại
  Future<Either<Failure, bool>> logout();

  /// Quên mật khẩu - Gửi mã OTP
  ///
  /// [email] - Email người dùng
  /// Returns: true nếu thành công, Failure nếu thất bại
  Future<Either<Failure, bool>> forgotPassword(String email);

  /// Xác thực OTP
  ///
  /// [email] - Email người dùng
  /// [otp] - Mã OTP
  /// Returns: true nếu thành công, Failure nếu thất bại
  Future<Either<Failure, bool>> verifyOTP({
    required String email,
    required String otp,
  });

  /// Đặt lại mật khẩu
  ///
  /// [email] - Email người dùng
  /// [newPassword] - Mật khẩu mới
  /// Returns: true nếu thành công, Failure nếu thất bại
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String newPassword,
  });

  /// Lấy thông tin người dùng hiện tại
  ///
  /// Returns: User nếu đã đăng nhập, null nếu chưa đăng nhập
  Future<Either<Failure, User?>> getCurrentUser();

  /// Đăng nhập bằng Google
  ///
  /// Returns: AuthResult nếu thành công, Failure nếu thất bại
  Future<Either<Failure, AuthResult>> signInWithGoogle();
}
