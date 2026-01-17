// lib/domain/usecase/profile/update_avatar_usecase.dart
// Use case cập nhật avatar
// DEPRECATED: Không sử dụng Firebase Storage nữa, chỉ dùng avatar chữ cái

/*
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../respository_interfaces/profile_repository.dart';

class UpdateAvatarUseCase implements UseCase<String, UpdateAvatarParams> {
  final ProfileRepository repository;

  UpdateAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateAvatarParams params) async {
    return await repository.updateAvatar(params.imagePath);
  }
}

class UpdateAvatarParams extends Equatable {
  final String imagePath;

  const UpdateAvatarParams({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}
*/
