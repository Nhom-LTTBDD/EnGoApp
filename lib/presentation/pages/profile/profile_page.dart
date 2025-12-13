// lib/presentation/pages/profile/profile_page.dart
// Trang hồ sơ người dùng.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_assets.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../widgets/app_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'EnGo App',
      currentIndex: 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                kIconUser,
                width: 150,
                height: 150,
                colorFilter: ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),
              ),
              const SizedBox(height: 15),
              AppButton(
                onPressed: () {},
                icon: Icons.camera_alt,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.small,
                isFullWidth: false,
              ),

              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, color: kPrimaryColor),
                            const SizedBox(width: 10),
                            Text('Trần Văn A', style: kBody),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cake, color: kPrimaryColor),
                            const SizedBox(width: 10),
                            Text('01/01/2000', style: kBody),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.email, color: kPrimaryColor),
                            const SizedBox(width: 10),
                            Text('tranvana@example.com', style: kBody),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      icon: Icons.edit,
                      onPressed: () {},
                      variant: AppButtonVariant.borderSuccess,
                      size: AppButtonSize.small,
                      isFullWidth: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              AppButton(
                text: 'Logout',
                onPressed: () {},
                variant: AppButtonVariant.danger,
                size: AppButtonSize.small,
                isFullWidth: false,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '10',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kDanger,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SvgPicture.asset(kIconFire, width: 45, height: 55),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    onPressed: () {},
                    icon: Icons.dark_mode,
                    variant: AppButtonVariant.accent,
                    size: AppButtonSize.small,
                    isFullWidth: false,
                  ),
                  const SizedBox(width: 20),
                  AppButton(
                    onPressed: () {},
                    icon: Icons.language,
                    variant: AppButtonVariant.accent,
                    size: AppButtonSize.small,
                    isFullWidth: false,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    onPressed: () {},
                    text: '20 bộ từ',
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.xLarge,
                    isFullWidth: false,
                  ),
                  const SizedBox(width: 20),
                  AppButton(
                    onPressed: () {},
                    text: '15 bài học',
                    variant: AppButtonVariant.success,
                    size: AppButtonSize.xLarge,
                    isFullWidth: false,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              AppButton(
                onPressed: () {},
                text: 'Xem tiến trình học',
                variant: AppButtonVariant.accent,
                size: AppButtonSize.xLarge,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
