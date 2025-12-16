// lib/presentation/pages/auth/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Quên mật khẩu',
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
                labelText: 'Email',
                floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.verifyOtp);
              },
              text: 'Gửi yêu cầu',
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
