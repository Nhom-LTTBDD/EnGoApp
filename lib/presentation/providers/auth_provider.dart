/*
 * auth_provider.dart
 *
 * Chức năng:
 * - Quản lý authentication: login, logout, register, refresh token, current user, auth state persistence.
 *
 * Được sử dụng ở đâu:
 * - LoginScreen, SignupScreen, App shell (route guard), ProfileScreen.
 *
 * API (public/state) gợi ý:
 * - User? user;
 * - AuthState authState; // unauthenticated / authenticating / authenticated / error
 * - String? errorMessage;
 * - Future<void> login(String email, String password);
 * - Future<void> register(RegisterData data);
 * - Future<void> logout();
 * - Future<void> tryRestoreSession(); // load token from secure storage and validate
 *
 * Lưu ý kỹ thuật:
 * - Không lưu token trong plain storage; dùng flutter_secure_storage.
 * - Tách network calls vào AuthRepository; provider chỉ orchestration + persist.
 * - Xử lý token refresh transparently; nếu refresh fail => force logout.
 * - Emit events for app-wide listeners (e.g., Navigation to auth routes on unauthenticated).
 * - Test: mock AuthRepository, kiểm tra restore/login/logout flows và error handling.
 */
