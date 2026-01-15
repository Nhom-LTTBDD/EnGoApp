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
import '../presentation/pages/test/test_page.dart';
import '../presentation/pages//test/ielts_page.dart';
import '../presentation/pages/test/toeic_page.dart';
import '../presentation/pages/test/toeic_detail_page.dart';
import '../presentation/pages/test/toeic_test_taking_page.dart';
//Vocabulary
import '../presentation/pages/vocabulary/vocabulary_page.dart';
import '../presentation/pages/vocabulary/vocab_by_topic_page.dart';
import '../presentation/pages/vocabulary/vocab_menu_page.dart';
import '../presentation/pages/vocabulary/flashcard_page.dart';

//Grammar
import '../presentation/pages/grammar/grammar_page.dart';

// Domain entities
import '../domain/entities/toeic_test.dart';
import '../domain/entities/toeic_question.dart';

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
  static const String ielts = '/ielts';
  static const String toeic = '/toeic';
  static const String toeicDetail = '/toeic/detail';
  static const String toeicTestTaking = '/toeic/test-taking';
  static const String vocab = '/vocabulary'; //Vocabulary
  static const String vocabByTopic =
      '/vocabulary/by-topic'; //Vocabulary by topic
  static const String vocabMenu = '/vocabulary/menu'; //Vocabulary menu
  static const String flashcard = '/vocabulary/flashcard'; //Flashcard page
  // Grammar routes
  static const String grammar = '/grammar'; //Grammar main
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
      case AppRoutes.ielts:
        return MaterialPageRoute(builder: (_) => IeltsPage());
      case AppRoutes.toeic:
        return MaterialPageRoute(builder: (_) => ToeicPage());
      case AppRoutes.toeicDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final testId = args?['testId']?.toString() ?? '1';
        final testName = args?['testName'] as String? ?? 'TOEIC Test';
        final test = args?['test'] as ToeicTest?;
        final partNumber = args?['partNumber'] as int?;
        return MaterialPageRoute(
          builder: (_) => ToeicDetailPage(
            testId: testId,
            testName: testName,
            test: test,
            partNumber: partNumber,
          ),
        );
      case AppRoutes.toeicTestTaking:
        final args = settings.arguments as Map<String, dynamic>?;
        final questions = args?['questions'] as List<ToeicQuestion>?;
        return MaterialPageRoute(
          builder: (_) => ToeicTestTakingPage(
            testId: args?['testId']?.toString() ?? '1',
            testName: args?['testName'] as String? ?? 'TOEIC Test',
            isFullTest: args?['isFullTest'] as bool? ?? false,
            selectedParts: (args?['selectedParts'] as List?)?.cast<int>() ?? [],
            timeLimit: args?['timeLimit'] as int?,
            questions: questions,
          ),
        );
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

      // Grammar cases
      case AppRoutes.grammar:
        return MaterialPageRoute(builder: (_) => GrammarPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
