// lib/core/error/failure.dart
// Định nghĩa các loại lỗi trong ứng dụng

import 'package:equatable/equatable.dart';

/// Abstract class cho tất cả các lỗi
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Lỗi từ server
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Lỗi từ server']) : super(message);
}

/// Lỗi kết nối mạng
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Không có kết nối mạng'])
    : super(message);
}

/// Lỗi xác thực
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Lỗi xác thực']) : super(message);
}

/// Lỗi validation
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Dữ liệu không hợp lệ'])
    : super(message);
}

/// Lỗi cache
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Lỗi cache']) : super(message);
}

/// Lỗi không tìm thấy
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Không tìm thấy']) : super(message);
}

/// Lỗi không xác định
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Lỗi không xác định'])
    : super(message);
}
