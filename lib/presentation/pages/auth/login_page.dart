// lib/presentation/pages/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_button.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.logoOnly(),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: kBackgroundGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Đăng nhập', style: kFormTitle),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kSecondaryColor.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              width: 300,
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      floatingLabelStyle: TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      floatingLabelStyle: TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  AppButton(
                    text: 'Đăng nhập',
                    variant: AppButtonVariant.accent,
                    onPressed: () {
                      // Handle login action
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
                  ),
                  SizedBox(height: 25),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password action
                    },
                    child: Text('Quên mật khẩu?', style: kDangerText),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Handle register action
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: Column(
                      children: [
                        Text('Bạn chưa có tài khoản? ', style: kBody),
                        Text('Đăng ký', style: kBodyEmphasized),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
