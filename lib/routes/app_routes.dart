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
import '../presentation/pages/profile/edit_profile_page.dart';
//Test
import '../presentation/pages/main/test_page.dart';

//Vocabulary
import '../presentation/pages/vocabulary/vocabulary_page.dart';
import '../presentation/pages/vocabulary/vocab_by_topic_page.dart';
import '../presentation/pages/vocabulary/vocab_menu_page.dart';
import '../presentation/pages/vocabulary/flashcard_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String terms = '/terms';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String test = '/test'; //Test
  static const String vocab = '/vocabulary'; //Vocabulary
  static const String vocabByTopic =
      '/vocabulary/by-topic'; //Vocabulary by topic
  static const String vocabMenu = '/vocabulary/menu'; //Vocabulary menu
  static const String flashcard = '/vocabulary/flashcard'; //Flashcard page
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
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => EditProfilePage());
      //case Test
      case AppRoutes.test:
        return MaterialPageRoute(builder: (_) => TestPage());
      //case Vocab
      case AppRoutes.vocab:
        return MaterialPageRoute(builder: (_) => VocabPage());
      case AppRoutes.vocabByTopic:
        return MaterialPageRoute(builder: (_) => VocabByTopicPage());
      case AppRoutes.vocabMenu:
        final args = settings.arguments as Map<String, dynamic>?;
        final topicId = args?['topicId'] as String?;
        return MaterialPageRoute(
          builder: (_) => VocabMenuPage(topicId: topicId),
        );
      case AppRoutes.flashcard:
        final args = settings.arguments as Map<String, dynamic>?;
        final topicId = args?['topicId'] as String?;
        return MaterialPageRoute(
          builder: (_) => FlashcardPage(topicId: topicId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
