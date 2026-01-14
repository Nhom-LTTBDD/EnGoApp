// lib/data/datasources/profile_remote_datasource.dart
// Remote datasource cho Profile - Xử lý Firebase Firestore

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/error/failure.dart';
import '../../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  /// Lấy thông tin profile từ Firestore
  Future<UserModel> getUserProfile(String userId);

  /// Cập nhật thông tin profile
  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    String? birthDate,
  });

  /// Upload và cập nhật avatar
  Future<String> updateAvatar({
    required String userId,
    required String imagePath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.storage,
  });

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      // Try cache first for faster load
      final userDoc = await firestore
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.cache))
          .timeout(
            const Duration(milliseconds: 500),
            onTimeout: () => firestore.collection('users').doc(userId).get(),
          );

      if (!userDoc.exists) {
        // If not in cache, fetch from server
        final serverDoc = await firestore
            .collection('users')
            .doc(userId)
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 5));

        if (!serverDoc.exists) {
          throw const AuthFailure('Không tìm thấy thông tin người dùng');
        }

        final userData = serverDoc.data();
        if (userData == null) {
          throw const AuthFailure('Dữ liệu người dùng không hợp lệ');
        }
        return UserModel.fromJson({'id': userId, ...userData});
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw const AuthFailure('Dữ liệu người dùng không hợp lệ');
      }

      return UserModel.fromJson({'id': userId, ...userData});
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthFailure('Lỗi Firebase: ${e.message}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể lấy thông tin profile');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    String? birthDate,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (birthDate != null) {
        updateData['birthDate'] = birthDate;
      }

      await firestore
          .collection('users')
          .doc(userId)
          .update(updateData)
          .timeout(const Duration(seconds: 5));

      // Cập nhật display name trong Firebase Auth
      await firebaseAuth.currentUser?.updateDisplayName(name);

      // Lấy lại profile đã cập nhật
      return await getUserProfile(userId);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthFailure('Lỗi Firebase: ${e.message}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể cập nhật profile');
    }
  }

  @override
  Future<String> updateAvatar({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw const ValidationFailure('File không tồn tại');
      }

      // Upload file lên Firebase Storage
      final storageRef = storage.ref().child('avatars/$userId.jpg');
      final uploadTask = await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Lấy download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Cập nhật avatarUrl trong Firestore
      await firestore.collection('users').doc(userId).update({
        'avatarUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Cập nhật photoURL trong Firebase Auth
      await firebaseAuth.currentUser?.updatePhotoURL(downloadUrl);

      return downloadUrl;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthFailure('Lỗi Firebase: ${e.message}');
    } on FirebaseException catch (e) {
      throw ServerFailure('Lỗi upload ảnh: ${e.message}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure('Không thể upload avatar');
    }
  }
}
