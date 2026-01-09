// lib/core/di/injection_container.dart
// Dependency Injection Container - Setup tất cả dependencies

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
import '../../domain/usecase/auth/google_sign_in_usecase.dart';
import '../../domain/usecase/profile/get_user_profile_usecase.dart';
import '../../domain/usecase/profile/update_avatar_usecase.dart';
import '../../domain/usecase/profile/update_profile_usecase.dart';

// Presentation Layer
import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/providers/profile/profile_provider.dart';
import '../../presentation/providers/vocabulary_provider.dart';
import '../../presentation/providers/grammar_provider.dart';

// Vocabulary Domain
import '../../domain/repository_interfaces/vocabulary_repository.dart';
import '../../domain/usecase/get_vocabulary_cards.dart';

// Vocabulary Data
import '../../data/repositories/vocabulary_repository_impl.dart';

// Grammar Domain
import '../../domain/repository_interfaces/grammar_repository.dart';
import '../../domain/use_cases/get_grammar_topics_use_case.dart';
import '../../domain/use_cases/get_grammar_lessons_use_case.dart';

// Grammar Data
import '../../data/repositories/grammar_repository_impl.dart';

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
      googleSignInUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileProvider(
      getUserProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      updateAvatarUseCase: sl(),
    ),
  );

  sl.registerFactory(() => VocabularyProvider(getVocabularyCards: sl()));
  // Grammar Provider
  sl.registerFactory(
    () => GrammarProvider(
      getGrammarTopicsUseCase: sl(),
      getGrammarLessonsUseCase: sl(),
      grammarRepository: sl(),
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
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  // =============================================================================
  // Use Cases - Profile
  // =============================================================================
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));

  // =============================================================================
  // Use Cases - Vocabulary
  // =============================================================================
  sl.registerLazySingleton(() => GetVocabularyCards(sl()));

  // =============================================================================
  // Use Cases - Grammar
  // =============================================================================
  sl.registerLazySingleton(() => GetGrammarTopicsUseCase(sl()));
  sl.registerLazySingleton(() => GetGrammarLessonsUseCase(sl()));

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

  sl.registerLazySingleton<VocabularyRepository>(
    () => VocabularyRepositoryImpl(),
  );

  sl.registerLazySingleton<GrammarRepository>(
    () => GrammarRepositoryImpl(),
  );

  // =============================================================================
  // Data Sources - Remote
  // =============================================================================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      storage: sl(),
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
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
