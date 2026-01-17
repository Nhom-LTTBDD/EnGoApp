// lib/domain/usecase/auth/register_usecase.dart
// Use case cho chức năng đăng ký

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/auth_result.dart';
import '../../repository_interfaces/auth_repository.dart';

class RegisterUseCase implements UseCase<AuthResult, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      birthDate: params.birthDate,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String? birthDate;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    this.birthDate,
  });

  @override
  List<Object?> get props => [email, password, name, birthDate];
}
