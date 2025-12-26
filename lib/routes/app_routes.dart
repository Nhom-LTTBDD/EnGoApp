// lib/routes/app_routes.dart
// Đây là file định nghĩa các tuyến đường (routes) trong ứng dụng EnGo App.
import 'package:flutter/material.dart';
import '../presentation/pages/welcome/splash_page.dart';
import '../presentation/pages/welcome/welcome_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/forgot_password_page.dart';
import '../presentation/pages/auth/terms_page.dart';
import '../presentation/pages/main/home_page.dart';
import '../presentation/pages/profile/profile_page.dart';
//Test
import '../presentation/pages/main/test_page.dart';

//Vocabulary
import '../presentation/pages/vocabulary/vocabulary_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String terms = '/terms';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String test = '/test'; //Test
  static const String vocab = '/vocabulary'; //Vocabulary
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
      case AppRoutes.terms:
        return MaterialPageRoute(builder: (_) => TermsPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      //case Test
      case AppRoutes.test:
        return MaterialPageRoute(builder: (_) => TestPage());
      //case Vocab
      case AppRoutes.vocab:
        return MaterialPageRoute(builder: (_) => VocabPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
