// lib/presentation/pages/welcome/splash_page.dart
import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../welcome/welcome_page.dart';
import '../../widgets/app_header.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Simulate some initialization work
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'EnGo App', elevation: 0.0),
      body: Center(
        child: Text(
          'Welcome to EnGo App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
