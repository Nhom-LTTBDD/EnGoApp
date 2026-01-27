// lib/presentation/pages/vocabulary/personal_vocabulary_page.dart

/// # PersonalVocabularyPage - Presentation Layer
/// 
/// **Purpose:** Redirect page - chuyển hướng ngay đến PersonalVocabularyByTopicPage
/// **Note:** Đây là wrapper page cho routing, không có UI logic

import 'package:flutter/material.dart';
import 'package:en_go_app/routes/app_routes.dart';

/// Trang hiển thị bộ từ vựng cá nhân của người dùng
/// Redirects to PersonalVocabularyByTopicPage
class PersonalVocabularyPage extends StatelessWidget {
  const PersonalVocabularyPage({super.key});

  /// Build widget - thực hiện redirect ngay sau frame đầu tiên
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
