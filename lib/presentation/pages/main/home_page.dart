// lib/presentation/pages/main/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MainLayout(
      title: 'EnGo App',
      currentIndex: 0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                themeExt?.backgroundGradientColors ??
                [Colors.white, const Color(0xFFB2E0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo với container và shadow để nổi bật
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.blue.withOpacity(0.3)
                        : const Color(0xFF1196EF).withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                  if (!isDark)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: -5,
                      offset: const Offset(-5, -5),
                    ),
                ],
              ),
              child: SvgPicture.asset(
                isDark ? kIconEagleDark : kIconEagleLight,
                width: 160,
                height: 160,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Welcome to Home Page',
              style: kH1.copyWith(
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Vocabulary',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.vocab),
              variant: AppButtonVariant.borderSuccess,
              isFullWidth: false,
              size: AppButtonSize.large,
              width: 200,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Test',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.test),
              variant: AppButtonVariant.borderWarning,
              isFullWidth: false,
              size: AppButtonSize.large,
              width: 200,
            ),
            const SizedBox(height: 10),
            AppButton(
              text: 'Grammar',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.grammar),
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
