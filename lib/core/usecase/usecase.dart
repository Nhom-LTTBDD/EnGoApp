// lib/core/usecase/usecase.dart
// Base class cho tất cả các Use Case

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failure.dart';

/// Interface cho tất cả các Use Case
///
/// [Type] - Kiểu dữ liệu trả về
/// [Params] - Tham số đầu vào
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Params khi không cần tham số
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
