// lib/domain/usecase/profile/get_user_profile_usecase.dart
// Use case lấy thông tin profile người dùng

import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user.dart';
import '../../repository_interfaces/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<User, NoParams> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}
