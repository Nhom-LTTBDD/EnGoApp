// lib/domain/usecase/auth/google_sign_in_usecase.dart
// Use case để đăng nhập bằng Google

import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/auth_result.dart';
import '../../repository_interfaces/auth_repository.dart';

class GoogleSignInUseCase implements UseCase<AuthResult, NoParams> {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
