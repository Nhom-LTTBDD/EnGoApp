// lib/domain/usecase/auth/logout_usecase.dart
// Use case cho chức năng đăng xuất

import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../respository_interfaces/auth_repository.dart';

class LogoutUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.logout();
  }
}
