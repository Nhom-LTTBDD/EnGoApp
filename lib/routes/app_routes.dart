// lib/routes/app_routes.dart
// Đây là file định nghĩa các tuyến đường (routes) trong ứng dụng EnGo App.
import 'package:flutter/material.dart';
import '../presentation/pages/welcome/splash_page.dart';
import '../presentation/pages/welcome/welcome_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/forgot_password_page.dart';
import '../presentation/pages/auth/verify_otp_page.dart';
import '../presentation/pages/auth/reset_password_page.dart';
import '../presentation/pages/auth/terms_page.dart';
import '../presentation/pages/main/home_page.dart';
import '../presentation/pages/profile/profile_page.dart';
//Test
import '../presentation/pages/main/test_page.dart';
import '../presentation/pages/main/tests/ielts_page.dart';
import '../presentation/pages/main/tests/toeic_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String terms = '/terms';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String test = '/test'; //Test
  static const String ielts = '/ielts';
  static const String toeic = '/toeic';
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
      case AppRoutes.verifyOtp:
        return MaterialPageRoute(builder: (_) => VerifyOtpPage());
      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => ResetPasswordPage());
      case AppRoutes.terms:
        return MaterialPageRoute(builder: (_) => TermsPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      //case Test
      case AppRoutes.test:
        return MaterialPageRoute(builder: (_) => TestPage());
      case AppRoutes.ielts:
        return MaterialPageRoute(builder: (_) => IeltsPage());
      case AppRoutes.toeic:
        return MaterialPageRoute(builder: (_) => ToeicPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
