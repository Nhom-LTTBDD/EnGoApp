// lib/presentation/pages/vocabulary/vocabulary_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../widgets/app_button.dart';

class VocabPage extends StatelessWidget {
  const VocabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'VOCABULARY',
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: kBackgroundColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              text: 'Các chủ đề từ vựng',
              onPressed: () {},
              variant: AppButtonVariant.borderSuccess,
              isFullWidth: false,
              size: AppButtonSize.xsLarge,
              width: 282,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Bộ từ của bạn',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.vocabByTopic);
              },
              variant: AppButtonVariant.borderWarning,
              isFullWidth: false,
              size: AppButtonSize.xsLarge,
              width: 282,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Flash Card',
              onPressed: () {},
              variant: AppButtonVariant.borderSpecial,
              isFullWidth: false,
              size: AppButtonSize.xsLarge,
              width: 282,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Quiz',
              onPressed: () {},
              variant: AppButtonVariant.borderSpecial,
              isFullWidth: false,
              size: AppButtonSize.xsLarge,
              width: 282,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Grammar',
              onPressed: () {},
              variant: AppButtonVariant.borderSpecial,
              isFullWidth: false,
              size: AppButtonSize.xsLarge,
              width: 282,
            ),
          ],
        ),
      ),
    );
  }
}
