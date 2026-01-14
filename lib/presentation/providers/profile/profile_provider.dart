// lib/presentation/providers/profile/profile_provider.dart
// Provider quản lý profile state và actions

import 'package:flutter/foundation.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecase/profile/clear_profile_cache_usecase.dart';
import '../../../domain/usecase/profile/get_user_profile_usecase.dart';
import '../../../domain/usecase/profile/update_avatar_color_usecase.dart';
import '../../../domain/usecase/profile/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateAvatarColorUseCase updateAvatarColorUseCase;
  final ClearProfileCacheUseCase clearProfileCacheUseCase;

  ProfileState _state = ProfileInitial();
  ProfileState get state => _state;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false; // Track loading để tránh duplicate calls

  ProfileProvider({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateAvatarColorUseCase,
    required this.clearProfileCacheUseCase,
  });

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Lấy thông tin profile
  Future<void> getUserProfile({bool force = false}) async {
    // Tránh duplicate calls nếu đang load và không force
    if (_isLoading && !force) return;

    // Nếu đã có data và không force, skip
    if (_currentUser != null && !force && _state is! ProfileError) return;

    _isLoading = true;
    _setState(ProfileLoading());

    final result = await getUserProfileUseCase(NoParams());

    result.fold(
      (failure) {
        _isLoading = false;
        _setState(ProfileError(failure.message));
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        _setState(ProfileLoaded(user));
      },
    );
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

  /// Cập nhật màu avatar
  Future<void> updateAvatarColor(String color) async {
    _setState(ProfileUpdating());

    final result = await updateAvatarColorUseCase(
      UpdateAvatarColorParams(color: color),
    );

    result.fold((failure) => _setState(ProfileError(failure.message)), (user) {
      _currentUser = user;
      _setState(ProfileUpdated(user));
    });
  }

  /// Reset về trạng thái initial và xóa cache
  void reset() {
    _currentUser = null;
    _isLoading = false;
    _setState(ProfileInitial());
    // Xóa cache profile để load data mới
    clearProfileCacheUseCase(NoParams());
  }
}
