// lib/presentation/pages/main/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Ngăn swipe back vì đây là trang chính
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        // Không làm gì - giữ user ở trang home
        // Đây là trang chính, không có trang trước để quay về
      },
      child: MainLayout(
        title: 'EnGo App',
        currentIndex: 0,
        child: RepaintBoundary(
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
                    color: getSurfaceColor(
                      context,
                    ).withOpacity(isDark ? 0.1 : 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
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
                  style: kH1.copyWith(color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  color: 'blue',
                  text: 'Vocabulary',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.vocab),
                ),
                const SizedBox(height: 10),
                _buildMenuButton(
                  context,
                  color: 'green',
                  text: 'Test',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.test),
                ),
                const SizedBox(height: 10),
                _buildMenuButton(
                  context,
                  color: 'special',
                  text: 'Grammar',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.grammar),
                ),
                const SizedBox(height: 10),
                _buildMenuButton(
                  context,
                  color: 'blue',
                  text: 'Translation',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.translation),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String text,
    required String color,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor;
    if (color == 'blue') {
      buttonColor = isDark ? kPrimaryColor : kSecondaryColor;
    } else if (color == 'green') {
      buttonColor = isDark ? kSuccess : kSuccess;
    } else {
      buttonColor = isDark ? kSpecial : kSpecial;
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: getSurfaceColor(context).withOpacity(isDark ? 0.1 : 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: buttonColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: kBodyEmphasized.copyWith(
            color: isDark ? getTextPrimary(context) : buttonColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
