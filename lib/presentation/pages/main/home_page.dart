// lib/presentation/pages/main/home_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';
import '../../widgets/navbar_bottom.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'EnGo App',
      currentIndex: 0,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(kBackgroundJpg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(kEaglePng, width: 200, height: 200),
            const SizedBox(height: 20),
            Text('Welcome to Home Page', style: kH1),
            const SizedBox(height: 20),
            AppButton(
              text: 'Vocabulary',
              onPressed: () {},
              variant: AppButtonVariant.borderSuccess,
              isFullWidth: false,
              size: AppButtonSize.large,
              width: 200,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Test',
              onPressed: () {},
              variant: AppButtonVariant.borderWarning,
              isFullWidth: false,
              size: AppButtonSize.large,
              width: 200,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Grammar',
              onPressed: () {},
              variant: AppButtonVariant.borderSpecial,
              isFullWidth: false,
              size: AppButtonSize.large,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
