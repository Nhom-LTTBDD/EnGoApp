// lib/presentation/pages/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_assets.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _hasNavigated = false; // Prevent multiple navigations
  bool _isGoogleSignInProcessing = false; // Prevent double tap

  @override
  void initState() {
    super.initState();
    // REMOVED: Focus listeners that cause unnecessary rebuilds
    // The UI will update automatically via decoration changes
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthProvider>().login(
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
          final authState = authProvider.state;

          // Handle navigation and errors - with debounce
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _hasNavigated) return;

            if (authState is Authenticated) {
              _hasNavigated = true;

              // Delay navigation để UI có thời gian render
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  authProvider.reset();
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                }
              });
            } else if (authState is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authState.message),
                  backgroundColor: kDanger,
                  duration: const Duration(seconds: 2),
                ),
              );
              authProvider.reset();
            }
          });

          final isLoading = authState is AuthLoading;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'vd: name@domain.com',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey.shade600,
                      ),
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
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',

                      hintText: 'Nhập mật khẩu của bạn',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                      ),
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
                  const SizedBox(height: 24),

                  // Login Button
                  Opacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: AppButton(
                        text: isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                        variant: AppButtonVariant.accent,
                        size: AppButtonSize.large,
                        onPressed: isLoading ? null : _handleLogin,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign In
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _isGoogleSignInProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kPrimaryColor,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              kIconGoogle,
                              width: 20,
                              height: 20,
                            ),
                      label: Text(
                        _isGoogleSignInProcessing
                            ? 'Đang xử lý...'
                            : 'Đăng nhập với Google',
                        style: TextStyle(
                          color: (isLoading || _isGoogleSignInProcessing)
                              ? Colors.black87
                              : Colors.black,
                        ),
                      ),
                      onPressed: (isLoading || _isGoogleSignInProcessing)
                          ? null
                          : () async {
                              if (_isGoogleSignInProcessing) return;
                              setState(() => _isGoogleSignInProcessing = true);

                              // Unfocus để ẩn keyboard và giảm work
                              FocusScope.of(context).unfocus();

                              // Delay nhỏ để UI update trước
                              await Future.delayed(
                                const Duration(milliseconds: 50),
                              );

                              if (mounted) {
                                await context
                                    .read<AuthProvider>()
                                    .signInWithGoogle();
                              }

                              if (mounted) {
                                setState(
                                  () => _isGoogleSignInProcessing = false,
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade600, width: 1),
                        disabledForegroundColor: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Forgot Password
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          ),
                    child: Text('Quên mật khẩu?', style: kDangerText),
                  ),
                  const SizedBox(height: 8),

                  // Register Link
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                    child: RichText(
                      text: TextSpan(
                        text: 'Bạn chưa có tài khoản? ',
                        style: kBody,
                        children: [
                          TextSpan(text: 'Đăng ký', style: kBodyEmphasized),
                        ],
                      ),
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
