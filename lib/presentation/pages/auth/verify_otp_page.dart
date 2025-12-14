// lib/presentation/pages/auth/verify_otp_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Xác thực OTP',
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
                labelText: 'Mã OTP',
                floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.resetPassword);
              },
              text: 'Xác thực',
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
