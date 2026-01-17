// lib/domain/usecase/auth/forgot_password_usecase.dart
// Use case cho chức năng quên mật khẩu

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../repository_interfaces/auth_repository.dart';

class ForgotPasswordUseCase implements UseCase<bool, ForgotPasswordParams> {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ForgotPasswordParams params) async {
    return await repository.forgotPassword(params.email);
  }
}

class ForgotPasswordParams extends Equatable {
  final String email;

  const ForgotPasswordParams({required this.email});

  @override
  List<Object> get props => [email];
}
