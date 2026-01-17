// lib/domain/usecase/profile/update_profile_usecase.dart
// Use case cập nhật thông tin profile

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user.dart';
import '../../repository_interfaces/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      birthDate: params.birthDate,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String name;
  final String? birthDate;

  const UpdateProfileParams({required this.name, this.birthDate});

  @override
  List<Object?> get props => [name, birthDate];
}
