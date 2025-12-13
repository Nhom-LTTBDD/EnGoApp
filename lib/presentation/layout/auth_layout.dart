// lib/presentation/layout/auth_layout.dart
// Đây là file định nghĩa bố cục (layout) chung cho các trang xác thực trong ứng dụng EnGo App.
import 'package:flutter/material.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import '../widgets/app_header.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AuthLayout({Key? key, required this.title, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'EnGo App', elevation: 0.0),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: kFormTitle),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
