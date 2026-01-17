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
import '../../domain/repository_interfaces/auth_repository.dart';
import '../../domain/repository_interfaces/profile_repository.dart';
import '../../domain/usecases/auth/forgot_password_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/google_sign_in_usecase.dart';
import '../../domain/usecases/profile/clear_profile_cache_usecase.dart';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_avatar_color_usecase.dart';
import '../../domain/usecases/profile/update_profile_usecase.dart';

// Presentation Layer
import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/providers/profile/profile_provider.dart';
import '../../presentation/providers/vocabulary_provider.dart';
import '../../presentation/providers/grammar_provider.dart';
import '../../presentation/providers/personal_vocabulary_provider.dart';
import '../../presentation/providers/streak_provider.dart';

// Vocabulary Domain
import '../../domain/repository_interfaces/vocabulary_repository.dart';
import '../../domain/usecases/vocabulary/get_vocabulary_cards.dart';
import '../../domain/usecases/vocabulary/enrich_vocabulary_card.dart';

// Vocabulary Data
import '../../data/repositories/vocabulary_repository_impl.dart';

// Dictionary Domain
import '../../domain/repository_interfaces/dictionary_repository.dart';

// Dictionary Data
import '../../data/repositories/dictionary_repository_impl.dart';
import '../../data/datasources/dictionary_remote_data_source.dart';
import '../../data/datasources/dictionary_local_data_source.dart';

// Grammar Domain
import '../../domain/repository_interfaces/grammar_repository.dart';
import '../../domain/usecases/grammar/get_grammar_topics_use_case.dart';
import '../../domain/usecases/grammar/get_grammar_lessons_use_case.dart';

// Grammar Data
import '../../data/repositories/grammar_repository_impl.dart';

// Services
import '../services/audio_service.dart';
import '../services/personal_vocabulary_service.dart';
import '../services/streak_service.dart';

final sl = GetIt.instance;

/// Initialize tất cả dependencies
/// ⚠️ THỨ TỰ QUAN TRỌNG: External → DataSources → Repositories → Use Cases → Providers
Future<void> init() async {
  // =============================================================================
  // External Dependencies (MUST BE FIRST)
  // =============================================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());

  // Firebase services
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Services
  sl.registerLazySingleton(() => AudioService());
  sl.registerLazySingleton(
    () => PersonalVocabularyService(
      sl(), // SharedPreferences
      firestore: sl(), // FirebaseFirestore
    ),
  );
  sl.registerLazySingleton(
    () => StreakService(
      sl(), // SharedPreferences
      firestore: sl(), // FirebaseFirestore
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

  sl.registerLazySingleton<DictionaryLocalDataSource>(
    () => DictionaryLocalDataSourceImpl(sharedPreferences: sl()),
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

  sl.registerLazySingleton<DictionaryRemoteDataSource>(
    () => DictionaryRemoteDataSourceImpl(client: sl()),
  );

  // =============================================================================
  // Repositories (MUST BE BEFORE USE CASES)
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

  sl.registerLazySingleton<DictionaryRepository>(
    () =>
        DictionaryRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<GrammarRepository>(() => GrammarRepositoryImpl());

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
  sl.registerLazySingleton(() => UpdateAvatarColorUseCase(sl()));
  sl.registerLazySingleton(() => ClearProfileCacheUseCase(sl()));

  // =============================================================================
  // Use Cases - Vocabulary
  // =============================================================================
  sl.registerLazySingleton(() => GetVocabularyCards(sl()));
  sl.registerLazySingleton(() => EnrichVocabularyCard(sl()));

  // =============================================================================
  // Use Cases - Grammar
  // =============================================================================
  sl.registerLazySingleton(() => GetGrammarTopicsUseCase(sl()));
  sl.registerLazySingleton(() => GetGrammarLessonsUseCase(sl()));

  // =============================================================================
  // Providers (State Management) - MUST BE LAST
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
      updateAvatarColorUseCase: sl(),
      clearProfileCacheUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => VocabularyProvider(
      getVocabularyCards: sl(),
      enrichVocabularyCard: sl(),
    ),
  );
  sl.registerFactory(
    () => PersonalVocabularyProvider(
      service: sl(),
      vocabularyRepository: sl(),
      dictionaryRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => GrammarProvider(
      getGrammarTopicsUseCase: sl(),
      getGrammarLessonsUseCase: sl(),
      grammarRepository: sl(),
    ),
  );

  sl.registerFactory(() => StreakProvider(streakService: sl()));
}
