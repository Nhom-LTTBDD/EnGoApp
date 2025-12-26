// lib/presentation/pages/auth/reset_password_page.dart
// File này đã không còn được sử dụng do đã chuyển sang Firebase Password Reset
// Giữ lại để tránh lỗi import nhưng sẽ redirect về login

import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect về login page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
