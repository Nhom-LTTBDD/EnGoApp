// lib/domain/usecase/auth/reset_password_usecase.dart
// Use case cho chức năng đặt lại mật khẩu

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../repository_interfaces/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<bool, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      email: params.email,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String email;
  final String newPassword;

  const ResetPasswordParams({required this.email, required this.newPassword});

  @override
  List<Object> get props => [email, newPassword];
}
