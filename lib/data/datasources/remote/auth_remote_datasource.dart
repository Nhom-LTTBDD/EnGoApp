// lib/data/datasources/auth_remote_datasource.dart
// Remote datasource cho Auth - Xử lý Firebase Authentication

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/error/failure.dart';
import '../../models/auth_result_model.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Đăng nhập qua API
  Future<AuthResultModel> login({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới qua API
  Future<AuthResultModel> register({
    required String email,
    required String password,
    required String name,
    String? birthDate,
  });

  /// Đăng xuất qua API
  Future<bool> logout();

  /// Gửi OTP qua email
  Future<bool> forgotPassword(String email);

  /// Xác thực OTP
  Future<bool> verifyOTP({required String email, required String otp});

  /// Đặt lại mật khẩu
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  });

  /// Lấy thông tin user từ server
  Future<UserModel?> getCurrentUser();

  /// Đăng nhập bằng Google
  Future<AuthResultModel> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    GoogleSignIn? googleSignIn,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Đăng nhập thất bại');
      }

      // Lấy thông tin user từ Firestore
      final userDoc = await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      final userData = userDoc.data();
      if (userData == null) {
        throw const AuthFailure('Không tìm thấy thông tin người dùng');
      }

      final user = UserModel.fromJson({
        'id': credential.user!.uid,
        'email': credential.user!.email,
        ...userData,
      });

      return AuthResultModel(user: user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw const AuthFailure('Email hoặc mật khẩu không đúng');
      } else if (e.code == 'invalid-email') {
        throw const ValidationFailure('Email không hợp lệ');
      } else if (e.code == 'user-disabled') {
        throw const AuthFailure('Tài khoản đã bị vô hiệu hóa');
      } else {
        throw AuthFailure('Lỗi đăng nhập: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<AuthResultModel> register({
    required String email,
    required String password,
    required String name,
    String? birthDate,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure('Đăng ký thất bại');
      }

      // Tạo user document trong Firestore
      final userData = {
        'email': email,
        'name': name,
        'birthDate': birthDate,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      // Cập nhật display name
      await credential.user!.updateDisplayName(name);

      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        birthDate: birthDate,
      );

      return AuthResultModel(user: user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const ValidationFailure('Email đã được sử dụng');
      } else if (e.code == 'weak-password') {
        throw const ValidationFailure('Mật khẩu quá yếu (tối thiểu 6 ký tự)');
      } else if (e.code == 'invalid-email') {
        throw const ValidationFailure('Email không hợp lệ');
      } else {
        throw AuthFailure('Lỗi đăng ký: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await firebaseAuth.signOut();
      return true;
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể đăng xuất');
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      print('🔄 Đang gửi email reset password đến: $email');
      await firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Email reset password đã được gửi thành công!');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw const NotFoundFailure('Email không tồn tại');
      } else if (e.code == 'invalid-email') {
        throw const ValidationFailure('Email không hợp lệ');
      } else {
        throw AuthFailure('Lỗi Firebase Auth: ${e.code} - ${e.message}');
      }
    } catch (e) {
      print('❌ Lỗi không xác định: $e');
      if (e is Failure) rethrow;
      throw NetworkFailure('Không thể kết nối đến server: $e');
    }
  }

  @override
  Future<bool> verifyOTP({required String email, required String otp}) async {
    // Không cần implement vì đã xóa OTP flow
    throw UnimplementedError('OTP verification đã được loại bỏ');
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // Không cần implement vì Firebase xử lý qua email
    throw UnimplementedError('Reset password được xử lý qua email link');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        return null;
      }

      // Lấy thông tin user từ cache first, fallback to server
      final userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get(const GetOptions(source: Source.cache))
          .timeout(
            const Duration(milliseconds: 300),
            onTimeout: () => firestore
                .collection('users')
                .doc(currentUser.uid)
                .get(const GetOptions(source: Source.server))
                .timeout(const Duration(seconds: 3)),
          );

      final userData = userDoc.data();
      if (userData == null) {
        throw const AuthFailure('Không tìm thấy thông tin người dùng');
      }

      return UserModel.fromJson({
        'id': currentUser.uid,
        'email': currentUser.email,
        ...userData,
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw const AuthFailure('Người dùng không tồn tại');
      } else {
        throw AuthFailure('Lỗi: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến server');
    }
  }

  @override
  Future<AuthResultModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthFailure('Đăng nhập Google bị hủy');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthFailure('Đăng nhập Google thất bại');
      }

      final user = userCredential.user!;

      // Check if user exists in Firestore with timeout
      final userDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 5));

      if (!userDoc.exists) {
        // Create new user document
        final userData = {
          'email': user.email,
          'name': user.displayName ?? 'User',
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await firestore
            .collection('users')
            .doc(user.uid)
            .set(userData)
            .timeout(const Duration(seconds: 5));
      }

      // Get user data from cache or server
      final updatedUserDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 3));
      final userData = updatedUserDoc.data() ?? {};

      final userModel = UserModel.fromJson({
        'id': user.uid,
        'email': user.email,
        'name': user.displayName ?? userData['name'] ?? 'User',
        'photoUrl': user.photoURL ?? userData['photoUrl'],
        ...userData,
      });

      return AuthResultModel(user: userModel);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw const AuthFailure(
          'Tài khoản đã tồn tại với phương thức đăng nhập khác',
        );
      } else if (e.code == 'invalid-credential') {
        throw const AuthFailure('Thông tin xác thực không hợp lệ');
      } else {
        throw AuthFailure('Lỗi đăng nhập Google: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể kết nối đến Google');
    }
  }
}
