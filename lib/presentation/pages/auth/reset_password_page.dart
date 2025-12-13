// lib/presentation/pages/auth/reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Đặt lại mật khẩu',
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kSecondaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: () {
                // Handle reset password action
                Navigator.pushNamed(context, AppRoutes.login);
              },
              text: 'Đặt lại mật khẩu',
              variant: AppButtonVariant.primary,
              size: AppButtonSize.large,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
