// lib/presentation/pages/auth/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthState? _previousAuthState;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      authProvider.forgotPassword(_emailController.text.trim());
    }
  }

  /// Xử lý state changes
  void _handleAuthStateChange(BuildContext context, AuthState authState) {
    // Chỉ handle khi state thực sự thay đổi
    if (_previousAuthState == authState) return;
    _previousAuthState = authState;

    if (authState is PasswordReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email đặt lại mật khẩu đã được gửi! Vui lòng kiểm tra hộp thư của bạn.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
          context.read<AuthProvider>().reset();
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    } else if (authState is AuthError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.message),
              backgroundColor: kDanger,
            ),
          );
          context.read<AuthProvider>().reset();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Quên mật khẩu',
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final authState = authProvider.state;
          final isLoading = authState is AuthLoading;

          // Handle state changes
          _handleAuthStateChange(context, authState);

          return Container(
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Nhập email của bạn để nhận link đặt lại mật khẩu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: kTextPrimary),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: kTextPrimary),
                    decoration: InputDecoration(
                      labelText: 'Email',

                      hintText: 'vd: name@domain.com',
                      hintStyle: TextStyle(
                        color: kTextPrimary.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: isLoading ? kPrimaryColor : kTextPrimary,
                      ),
                      floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                          width: 2.5,
                        ),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: kDanger, width: 1.5),
                      ),
                      filled: true,
                      fillColor: isLoading ? Colors.grey.shade50 : Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleForgotPassword(context),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Opacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: AppButton(
                        onPressed: isLoading
                            ? null
                            : () => _handleForgotPassword(context),
                        text: isLoading
                            ? 'Đang gửi...'
                            : 'Gửi email đặt lại mật khẩu',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.large,
                        isFullWidth: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          ),
                    child: const Text(
                      'Quay lại đăng nhập',
                      style: TextStyle(color: kPrimaryColor),
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
