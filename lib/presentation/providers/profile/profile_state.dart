// lib/presentation/providers/profile/profile_state.dart
// Các trạng thái của Profile

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// Base Profile State
abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class ProfileInitial extends ProfileState {}

/// Đang tải
class ProfileLoading extends ProfileState {}

/// Đã tải profile
class ProfileLoaded extends ProfileState {
  final User user;

  ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// Đang cập nhật
class ProfileUpdating extends ProfileState {}

/// Cập nhật thành công
class ProfileUpdated extends ProfileState {
  final User user;

  ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Đang upload avatar
class AvatarUploading extends ProfileState {}

/// Avatar đã cập nhật
class AvatarUpdated extends ProfileState {
  final String avatarUrl;

  AvatarUpdated(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

/// Lỗi
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
