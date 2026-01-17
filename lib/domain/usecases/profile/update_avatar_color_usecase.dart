// lib/domain/usecase/profile/update_avatar_color_usecase.dart
// Use case cập nhật màu avatar tùy chỉnh

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user.dart';
import '../../repository_interfaces/profile_repository.dart';

class UpdateAvatarColorUseCase
    implements UseCase<User, UpdateAvatarColorParams> {
  final ProfileRepository repository;

  UpdateAvatarColorUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateAvatarColorParams params) async {
    return await repository.updateAvatarColor(params.color);
  }
}

class UpdateAvatarColorParams extends Equatable {
  final String color;

  const UpdateAvatarColorParams({required this.color});

  @override
  List<Object> get props => [color];
}
