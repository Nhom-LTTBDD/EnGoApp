// lib/presentation/pages/welcome/splash_page.dart
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

  /// Kiểm tra auth status và navigate đến trang phù hợp
  Future<void> _checkAuthAndNavigate() async {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'EnGo App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
