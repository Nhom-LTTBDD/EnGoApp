import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth/auth_provider.dart';
import 'presentation/providers/auth/auth_state.dart'; //  Import AuthState
import 'presentation/providers/profile/profile_provider.dart';
import 'presentation/providers/vocabulary_provider.dart';
import 'presentation/providers/flashcard_provider.dart'; //  Import FlashcardProvider
import 'presentation/providers/personal_vocabulary_provider.dart';
import 'presentation/providers/grammar_provider.dart';
import 'presentation/providers/theme/theme_provider.dart';
import 'presentation/providers/toeic_test_provider.dart';
import 'presentation/providers/profile/streak_provider.dart';
import 'presentation/providers/flashcard_progress_provider.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Firestore for better performance
      final firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: true, // Enable offline persistence
        cacheSizeBytes: 10485760, // 10MB cache thay vì unlimited để giảm memory
      );

      // Initialize DI
      await di.init();

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('Initialization error: $e');
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (!_initialized && !_error) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Color(0xFF1196EF)),
                SizedBox(height: 16),
                Text('Loading...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    // Show error screen if initialization failed
    if (_error) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Initialization Error'))),
      );
    } // App initialized successfully
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),

        // ⚠️ AuthProvider PHẢI được tạo TRƯỚC PersonalVocabularyProvider
        ChangeNotifierProxyProvider<ProfileProvider, AuthProvider>(
          create: (_) => di.sl<AuthProvider>(),
          update: (_, profileProvider, authProvider) {
            // Setup callback để reset ProfileProvider khi logout
            authProvider!.onLogout = profileProvider.reset;
            // Setup callback để reset ProfileProvider khi login/register thành công
            authProvider.onAuthSuccess = profileProvider.reset;
            return authProvider;
          },
        ),

        // 🆕 PersonalVocabularyProvider listen AuthProvider để lấy userId
        ChangeNotifierProxyProvider<AuthProvider, PersonalVocabularyProvider>(
          create: (_) => di.sl<PersonalVocabularyProvider>(),
          update: (_, authProvider, personalVocabProvider) {
            // Khi user login/logout, update userId trong PersonalVocabularyProvider
            if (authProvider.state is Authenticated) {
              final user = (authProvider.state as Authenticated).user;
              print('Auth state: Authenticated - Setting userId: ${user.id}');
              // Chạy async để không block main thread
              Future.microtask(() => personalVocabProvider?.setUserId(user.id));
            } else {
              print(
                'Auth state: Not authenticated - ${authProvider.state.runtimeType}',
              );
            }
            return personalVocabProvider ?? di.sl<PersonalVocabularyProvider>();
          },
        ),

        //StreakProvider listen AuthProvider để lấy userId
        ChangeNotifierProxyProvider<AuthProvider, StreakProvider>(
          create: (_) => di.sl<StreakProvider>(),
          update: (_, authProvider, streakProvider) {
            // Khi user login/logout, update userId trong StreakProvider
            if (authProvider.state is Authenticated) {
              final user = (authProvider.state as Authenticated).user;
              print('Streak: Setting userId: ${user.id}');
              // Chạy async để không block main thread
              Future.microtask(() => streakProvider?.setUserId(user.id));
            }
            return streakProvider ?? di.sl<StreakProvider>();
          },
        ),

        //FlashcardProgressProvider listen AuthProvider để lấy userId
        ChangeNotifierProxyProvider<AuthProvider, FlashcardProgressProvider>(
          create: (_) => di.sl<FlashcardProgressProvider>(),
          update: (_, authProvider, progressProvider) {
            // Khi user login/logout, update userId trong FlashcardProgressProvider
            if (authProvider.state is Authenticated) {
              final user = (authProvider.state as Authenticated).user;
              print('FlashcardProgress: Setting userId: ${user.id}');
              // Chạy async để không block main thread
              Future.microtask(() => progressProvider?.setUserId(user.id));
            }
            return progressProvider ?? di.sl<FlashcardProgressProvider>();
          },
        ),

        ChangeNotifierProvider(create: (_) => di.sl<VocabularyProvider>()),
        ChangeNotifierProvider(
          create: (_) => FlashcardProvider(),
        ), // Add FlashcardProvider
        ChangeNotifierProvider(create: (_) => di.sl<GrammarProvider>()),

        // ToeicTestProvider - Khởi tạo lazy để không block main thread
        ChangeNotifierProvider(create: (_) => di.sl<ToeicTestProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'EnGo App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}
