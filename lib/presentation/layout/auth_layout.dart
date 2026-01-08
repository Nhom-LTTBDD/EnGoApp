// lib/presentation/layout/auth_layout.dart
// Đây là file định nghĩa bố cục (layout) chung cho các trang xác thực trong ứng dụng EnGo App.
import 'package:flutter/material.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import '../widgets/app_header.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AuthLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(title: 'EnGo App', elevation: 0),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: kFormTitle),
                        const SizedBox(height: 20),
                        child,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
