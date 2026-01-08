// lib/presentation/providers/profile/profile_provider.dart
// Provider quản lý profile state và actions

import 'package:flutter/foundation.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecase/profile/get_user_profile_usecase.dart';
import '../../../domain/usecase/profile/update_avatar_usecase.dart';
import '../../../domain/usecase/profile/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase;

  ProfileState _state = ProfileInitial();
  ProfileState get state => _state;

  User? _currentUser;
  User? get currentUser => _currentUser;

  ProfileProvider({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateAvatarUseCase,
  });

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Lấy thông tin profile
  Future<void> getUserProfile() async {
    _setState(ProfileLoading());

    final result = await getUserProfileUseCase(NoParams());

    result.fold((failure) => _setState(ProfileError(failure.message)), (user) {
      _currentUser = user;
      _setState(ProfileLoaded(user));
    });
  }

  /// Cập nhật thông tin profile
  Future<void> updateProfile({required String name, String? birthDate}) async {
    _setState(ProfileUpdating());

    final result = await updateProfileUseCase(
      UpdateProfileParams(name: name, birthDate: birthDate),
    );

    result.fold((failure) => _setState(ProfileError(failure.message)), (user) {
      _currentUser = user;
      _setState(ProfileUpdated(user));
    });
  }

  /// Cập nhật avatar
  Future<void> updateAvatar(String imagePath) async {
    _setState(AvatarUploading());

    final result = await updateAvatarUseCase(
      UpdateAvatarParams(imagePath: imagePath),
    );

    result.fold((failure) => _setState(ProfileError(failure.message)), (
      avatarUrl,
    ) {
      // Cập nhật avatar trong currentUser
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(avatarUrl: avatarUrl);
      }
      _setState(AvatarUpdated(avatarUrl));
    });
  }

  /// Reset về trạng thái initial
  void reset() {
    _currentUser = null;
    _setState(ProfileInitial());
  }
}
