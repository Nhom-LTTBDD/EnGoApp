// lib/domain/usecase/profile/clear_profile_cache_usecase.dart
// Use case xóa cache profile

import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../respository_interfaces/profile_repository.dart';

class ClearProfileCacheUseCase implements UseCase<void, NoParams> {
  final ProfileRepository repository;

  ClearProfileCacheUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearCache();
  }
}
