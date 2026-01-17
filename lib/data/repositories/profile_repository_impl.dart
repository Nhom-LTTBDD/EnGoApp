// lib/data/repositories/profile_repository_impl.dart
// Implementation của ProfileRepository interface

import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository_interfaces/profile_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/local/profile_local_datasource.dart';
import '../datasources/remote/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      // Lấy user hiện tại từ local storage
      final currentUser = await authLocalDataSource.getUser();
      if (currentUser == null) {
        return const Left(AuthFailure('Chưa đăng nhập'));
      }

      // Thử lấy từ cache trước
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        return Right(cachedProfile);
      }

      // Nếu không có cache, lấy từ Firestore
      final profile = await remoteDataSource.getUserProfile(currentUser.id);

      // Lưu vào cache
      await localDataSource.cacheProfile(profile);

      return Right(profile);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(UnknownFailure('Lỗi không xác định khi lấy profile'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? birthDate,
  }) async {
    try {
      // Lấy user hiện tại
      final currentUser = await authLocalDataSource.getUser();
      if (currentUser == null) {
        return const Left(AuthFailure('Chưa đăng nhập'));
      }

      // Gọi Firestore để cập nhật
      final updatedProfile = await remoteDataSource.updateProfile(
        userId: currentUser.id,
        name: name,
        birthDate: birthDate,
      );

      // Cập nhật cache
      await localDataSource.cacheProfile(updatedProfile);

      // Cập nhật user trong auth local storage
      await authLocalDataSource.saveUser(updatedProfile);

      return Right(updatedProfile);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(
        UnknownFailure('Lỗi không xác định khi cập nhật profile'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updateAvatarColor(String color) async {
    try {
      // Lấy user hiện tại
      final currentUser = await authLocalDataSource.getUser();
      if (currentUser == null) {
        return const Left(AuthFailure('Chưa đăng nhập'));
      }

      // Gọi Firestore để cập nhật
      final updatedProfile = await remoteDataSource.updateAvatarColor(
        userId: currentUser.id,
        color: color,
      );

      // Cập nhật cache
      await localDataSource.cacheProfile(updatedProfile);

      // Cập nhật user trong auth local storage
      await authLocalDataSource.saveUser(updatedProfile);

      return Right(updatedProfile);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(
        UnknownFailure('Lỗi không xác định khi cập nhật màu avatar'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      // Xóa profile cache
      await localDataSource.clearProfileCache();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(UnknownFailure('Lỗi không xác định khi xóa cache'));
    }
  }
}
