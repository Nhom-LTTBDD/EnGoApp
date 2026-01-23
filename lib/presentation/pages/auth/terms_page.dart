// lib/presentation/pages/auth/terms_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/presentation/widgets/common/app_button.dart';
import '../../../routes/app_routes.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Điều khoản dịch vụ',
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
            const Text(
              'Vui lòng đọc kỹ các điều khoản dịch vụ trước khi sử dụng ứng dụng EnGo App. Bằng việc sử dụng ứng dụng, bạn đồng ý với các điều khoản này.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.register);
              },
              text: 'Đồng ý và tiếp tục',
              variant: AppButtonVariant.primary,
              size: AppButtonSize.medium,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
