import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/providers/auth/auth_provider.dart';
import 'presentation/providers/profile/profile_provider.dart';
import 'presentation/providers/vocabulary_provider.dart';
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
    }

    // App initialized successfully
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<VocabularyProvider>()),
      ],
      child: MaterialApp(
        title: 'EnGo App',
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: const Color(0xFF1196EF),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
