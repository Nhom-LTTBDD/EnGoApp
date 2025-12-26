// lib/core/di/injection_container.dart
// Dependency Injection Container - Setup tất cả dependencies

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

// Data Layer
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/profile_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/profile_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';

// Domain Layer
import '../../domain/respository_interfaces/auth_repository.dart';
import '../../domain/respository_interfaces/profile_repository.dart';
import '../../domain/usecase/auth/forgot_password_usecase.dart';
import '../../domain/usecase/auth/get_current_user_usecase.dart';
import '../../domain/usecase/auth/login_usecase.dart';
import '../../domain/usecase/auth/logout_usecase.dart';
import '../../domain/usecase/auth/register_usecase.dart';
import '../../domain/usecase/profile/get_user_profile_usecase.dart';
import '../../domain/usecase/profile/update_avatar_usecase.dart';
import '../../domain/usecase/profile/update_profile_usecase.dart';

// Presentation Layer
import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/providers/profile/profile_provider.dart';

final sl = GetIt.instance;

/// Initialize tất cả dependencies
Future<void> init() async {
  // =============================================================================
  // Providers (State Management)
  // =============================================================================
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      forgotPasswordUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileProvider(
      getUserProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      updateAvatarUseCase: sl(),
    ),
  );

  // =============================================================================
  // Use Cases - Auth
  // =============================================================================
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // =============================================================================
  // Use Cases - Profile
  // =============================================================================
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));

  // =============================================================================
  // Repositories
  // =============================================================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // =============================================================================
  // Data Sources - Remote
  // =============================================================================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      client: sl(),
      baseUrl: 'https://api.engo.com', // Thay đổi theo API thực tế
    ),
  );

  // =============================================================================
  // Data Sources - Local
  // =============================================================================
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // =============================================================================
  // External Dependencies
  // =============================================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());

  // Firebase services
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
