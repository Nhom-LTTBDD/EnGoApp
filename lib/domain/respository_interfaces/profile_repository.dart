// lib/domain/respository_interfaces/profile_repository.dart
// Interface định nghĩa các phương thức liên quan đến profile

import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/user.dart';

abstract class ProfileRepository {
  /// Lấy thông tin profile người dùng
  ///
  /// Returns: User nếu thành công, Failure nếu thất bại
  Future<Either<Failure, User>> getUserProfile();

  /// Cập nhật thông tin profile
  ///
  /// [name] - Tên người dùng
  /// [birthDate] - Ngày sinh
  /// Returns: User đã cập nhật nếu thành công, Failure nếu thất bại
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? birthDate,
  });

  /// Cập nhật avatar
  ///
  /// [imagePath] - Đường dẫn ảnh local
  /// Returns: URL avatar mới nếu thành công, Failure nếu thất bại
  Future<Either<Failure, String>> updateAvatar(String imagePath);
}
