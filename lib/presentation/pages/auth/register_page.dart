import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Đăng ký',
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
                labelText: 'Họ và tên',
                floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Đăng ký',
              variant: AppButtonVariant.accent,
              size: AppButtonSize.large,
              onPressed: () {
                // TODO: implement register logic
              },
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () {
                // chuyển đến trang Terms and Conditions
                Navigator.pushNamed(context, AppRoutes.terms);
              },
              child: Text('Quy định và điều khoản', style: kBodyEmphasized),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Column(
                children: [
                  Text('Bạn đã có tài khoản?', style: kBody),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: Text('Đăng nhập', style: kBodyEmphasized),
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
