// lib/data/repositories/auth_repository_impl.dart
// Implementation của AuthRepository interface

import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository_interfaces/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Gọi API login
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Lưu user vào local storage (Firebase tự quản lý token)
      await localDataSource.saveUser(UserModel.fromEntity(result.user));

      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(UnknownFailure('Lỗi không xác định khi đăng nhập'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register({
    required String email,
    required String password,
    required String name,
    String? birthDate,
  }) async {
    try {
      // Gọi API register
      final result = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        birthDate: birthDate,
      );

      // Lưu user vào local storage (Firebase tự quản lý token)
      await localDataSource.saveUser(UserModel.fromEntity(result.user));

      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(UnknownFailure('Lỗi không xác định khi đăng ký'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // Gọi API logout (Firebase tự quản lý token)
      await remoteDataSource.logout();

      // Xóa dữ liệu local
      await localDataSource.clearAll();

      return const Right(true);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(UnknownFailure('Lỗi không xác định khi đăng xuất'));
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    try {
      final result = await remoteDataSource.forgotPassword(email);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(UnknownFailure('Lỗi không xác định khi gửi mã OTP'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.verifyOTP(email: email, otp: otp);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(UnknownFailure('Lỗi không xác định khi xác thực OTP'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final result = await remoteDataSource.resetPassword(
        email: email,
        newPassword: newPassword,
      );
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(
        UnknownFailure('Lỗi không xác định khi đặt lại mật khẩu'),
      );
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Kiểm tra user trong local storage trước
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser);
      }

      // Nếu không có local, gọi API (Firebase tự quản lý token)
      final user = await remoteDataSource.getCurrentUser();

      // Lưu vào local
      if (user != null) {
        await localDataSource.saveUser(user);
      }

      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(
        UnknownFailure('Lỗi không xác định khi lấy thông tin người dùng'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signInWithGoogle() async {
    try {
      // Gọi remote datasource để đăng nhập Google
      final result = await remoteDataSource.signInWithGoogle();

      // Lưu user vào local storage (Firebase tự quản lý token)
      await localDataSource.saveUser(UserModel.fromEntity(result.user));

      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(
        UnknownFailure('Lỗi không xác định khi đăng nhập Google'),
      );
    }
  }
}
