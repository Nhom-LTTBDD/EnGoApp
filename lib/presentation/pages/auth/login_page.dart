// lib/presentation/pages/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';
import '../../widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Đăng nhập',
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Listen to auth state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final state = authProvider.state;

            if (state is Authenticated) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: kDanger,
                ),
              );
            }
          });

          final isLoading = authProvider.state is AuthLoading;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kSecondaryColor.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      floatingLabelStyle: TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      floatingLabelStyle: TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                    obscureText: true,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: isLoading ? 'Đang xử lý...' : 'Đăng nhập',
                    variant: AppButtonVariant.accent,
                    size: AppButtonSize.large,
                    onPressed: isLoading ? null : () => _handleLogin(context),
                  ),
                  const SizedBox(height: 25),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.forgotPassword,
                            );
                          },
                    child: Text('Quên mật khẩu?', style: kDangerText),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
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
          );
        },
      ),
    );
  }
}
