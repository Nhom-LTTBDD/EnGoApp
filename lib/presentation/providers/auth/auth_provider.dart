// lib/presentation/providers/auth/auth_provider.dart
// Provider quản lý authentication state và actions

import 'package:flutter/foundation.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/usecase/auth/forgot_password_usecase.dart';
import '../../../domain/usecase/auth/get_current_user_usecase.dart';
import '../../../domain/usecase/auth/login_usecase.dart';
import '../../../domain/usecase/auth/logout_usecase.dart';
import '../../../domain/usecase/auth/register_usecase.dart';
import '../../../domain/usecase/auth/google_sign_in_usecase.dart';
import 'auth_state.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GoogleSignInUseCase googleSignInUseCase;

  AuthState _state = AuthInitial();
  AuthState get state => _state;

  // Callback để reset profile khi logout
  VoidCallback? onLogout;
  // Callback để reset profile khi login/register thành công
  VoidCallback? onAuthSuccess;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.forgotPasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.googleSignInUseCase,
    this.onLogout,
    this.onAuthSuccess,
  });

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Kiểm tra session khi khởi động app
  Future<void> checkAuthStatus() async {
    _setState(AuthLoading());

    final result = await getCurrentUserUseCase(NoParams());

    result.fold((failure) => _setState(Unauthenticated()), (user) {
      if (user != null) {
        _setState(Authenticated(user));
      } else {
        _setState(Unauthenticated());
      }
    });
  }

  /// Kiểm tra session khi khởi động app (silent - không trigger loading state)
  /// Dùng cho splash page để tránh setState during build
  Future<void> checkAuthStatusSilent() async {
    final result = await getCurrentUserUseCase(NoParams());

    result.fold((failure) => _setState(Unauthenticated()), (user) {
      if (user != null) {
        _setState(Authenticated(user));
      } else {
        _setState(Unauthenticated());
      }
    });
  }

  /// Đăng nhập
  Future<void> login({required String email, required String password}) async {
    _setState(AuthLoading());

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold((failure) => _setState(AuthError(failure.message)), (
      authResult,
    ) {
      // Reset ProfileProvider để load data mới
      onAuthSuccess?.call();
      _setState(Authenticated(authResult.user));
    });
  }

  /// Đăng ký
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? birthDate,
  }) async {
    _setState(AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: email,
        password: password,
        name: name,
        birthDate: birthDate,
      ),
    );

    result.fold((failure) => _setState(AuthError(failure.message)), (
      authResult,
    ) {
      // Reset ProfileProvider để load data mới
      onAuthSuccess?.call();
      _setState(Authenticated(authResult.user));
    });
  }

  /// Đăng xuất
  Future<void> logout() async {
    _setState(AuthLoading());

    final result = await logoutUseCase(NoParams());

    result.fold((failure) => _setState(AuthError(failure.message)), (_) {
      // Reset ProfileProvider khi logout
      onLogout?.call();
      _setState(Unauthenticated());
    });
  }

  /// Quên mật khẩu - Gửi email reset password
  Future<void> forgotPassword(String email) async {
    _setState(AuthLoading());

    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: email),
    );

    result.fold(
      (failure) => _setState(AuthError(failure.message)),
      (_) => _setState(PasswordReset()),
    );
  }

  /// Reset về trạng thái initial
  void reset() {
    _setState(AuthInitial());
  }

  /// Đăng nhập bằng Google
  Future<void> signInWithGoogle() async {
    _setState(AuthLoading());

    final result = await googleSignInUseCase(NoParams());

    result.fold((failure) => _setState(AuthError(failure.message)), (
      authResult,
    ) {
      // Reset ProfileProvider để load data mới
      onAuthSuccess?.call();
      _setState(Authenticated(authResult.user));
    });
  }
}
