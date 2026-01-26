// lib/presentation/pages/welcome/splash_page.dart
// Trang splash - màn hình khởi động app
// Kiểm tra trạng thái đăng nhập và điều hướng đến trang phù hợp

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Đợi build xong rồi mới check auth để tránh setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  /// Kiểm tra trạng thái xác thực và điều hướng đến trang phù hợp
  /// - Nếu đã đăng nhập: điều hướng đến home
  /// - Nếu chưa đăng nhập: điều hướng đến welcome page
  Future<void> _checkAuthAndNavigate() async {
    // Delay 1 giây để framework warmup và giảm startup frame drops
    await Future.delayed(const Duration(milliseconds: 1000));

    final authProvider = context.read<AuthProvider>();

    // Kiểm tra auth status (silent - không trigger loading state)
    await authProvider.checkAuthStatusSilent();

    if (!mounted) return;

    final authState = authProvider.state;

    // Navigate dựa trên auth state
    if (authState is Authenticated) {
      // User đã đăng nhập → đi thẳng home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // User chưa đăng nhập → đi welcome page
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Icon(Icons.school, size: 100, color: Colors.blue),
            SizedBox(height: 20),

            // App name
            Text(
              'EnGo App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),

            // Loading indicator
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
