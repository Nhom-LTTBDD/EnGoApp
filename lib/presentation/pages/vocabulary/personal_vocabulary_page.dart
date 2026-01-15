// lib/presentation/pages/vocabulary/personal_vocabulary_page.dart

import 'package:flutter/material.dart';
import 'package:en_go_app/routes/app_routes.dart';

/// Trang hiển thị bộ từ vựng cá nhân của người dùng
/// Redirects to PersonalVocabularyByTopicPage
class PersonalVocabularyPage extends StatelessWidget {
  const PersonalVocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to by-topic page immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.personalVocabByTopic,
      );
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
