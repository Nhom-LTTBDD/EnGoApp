// lib/data/repositories/profile_repository_impl.dart
// Implementation của ProfileRepository interface

import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/respository_interfaces/profile_repository.dart';
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
      // Lấy token
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return const Left(AuthFailure('Chưa đăng nhập'));
      }

      // Thử lấy từ cache trước
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        return Right(cachedProfile);
      }

      // Nếu không có cache, gọi API
      final profile = await remoteDataSource.getUserProfile(token);

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
      // Lấy token
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return const Left(AuthFailure('Chưa đăng nhập'));
      }

      // Gọi API cập nhật
      final updatedProfile = await remoteDataSource.updateProfile(
        token: token,
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
  Future<Either<Failure, String>> updateAvatar(String imagePath) async {
    try {
      // Lấy token
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return const Left(AuthFailure('Chưa đăng nhập'));
      }

      // Gọi API upload avatar
      final avatarUrl = await remoteDataSource.updateAvatar(
        token: token,
        imagePath: imagePath,
      );

      // Cập nhật cache với avatar mới
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        final updatedProfile = cachedProfile.copyWith(avatarUrl: avatarUrl);
        await localDataSource.cacheProfile(updatedProfile);
        await authLocalDataSource.saveUser(updatedProfile);
      }

      return Right(avatarUrl);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(
        UnknownFailure('Lỗi không xác định khi cập nhật avatar'),
      );
    }
  }
}
