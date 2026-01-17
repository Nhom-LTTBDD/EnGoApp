// lib/domain/usecase/auth/verify_otp_usecase.dart
// Use case cho chức năng xác thực OTP

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../repository_interfaces/auth_repository.dart';

class VerifyOTPUseCase implements UseCase<bool, VerifyOTPParams> {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyOTPParams params) async {
    return await repository.verifyOTP(email: params.email, otp: params.otp);
  }
}

class VerifyOTPParams extends Equatable {
  final String email;
  final String otp;

  const VerifyOTPParams({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}
