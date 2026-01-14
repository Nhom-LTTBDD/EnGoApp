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
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isProcessing = false; // Prevent multiple taps

  // Track state để tránh xử lý duplicate
  String? _lastProcessedState;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    // Prevent multiple taps
    if (_isProcessing) return;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);

      // Unfocus để hide keyboard ngay lập tức
      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Đăng nhập',
      child: Selector<AuthProvider, AuthState>(
        selector: (_, provider) => provider.state,
        shouldRebuild: (previous, current) => previous != current,
        builder: (context, authState, _) {
          // Listen to auth state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            final stateKey =
                '${authState.runtimeType}_${authState is AuthError ? authState.message : ""}';

            // Chỉ xử lý nếu state chưa được xử lý
            if (_lastProcessedState == stateKey) return;
            _lastProcessedState = stateKey;

            if (authState is Authenticated) {
              // Reset state tracking trước khi navigate
              _lastProcessedState = null;
              context.read<AuthProvider>().reset();
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            } else if (authState is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authState.message),
                  backgroundColor: kDanger,
                  duration: const Duration(seconds: 3),
                ),
              );
              // Reset về initial state sau khi show error
              setState(() => _isProcessing = false);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) context.read<AuthProvider>().reset();
              });
            }
          });

          final isLoading = authState is AuthLoading || _isProcessing;

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
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      floatingLabelStyle: TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
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
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      floatingLabelStyle: const TextStyle(color: kPrimaryColor),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor, width: 2),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _handleLogin(context),
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
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                      variant: AppButtonVariant.accent,
                      size: AppButtonSize.large,
                      onPressed: isLoading ? null : () => _handleLogin(context),
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Hoặc', style: kBody),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Image.asset(
                        'assets/icons/ic_google.png',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.g_mobiledata, size: 24);
                        },
                      ),
                      label: Text(
                        'Đăng nhập với Google',
                        style: kBodyEmphasized.copyWith(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              final authProvider = context.read<AuthProvider>();
                              authProvider.signInWithGoogle();
                            },
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                    child: Column(
                      children: [
                        Text('Bạn chưa có tài khoản? ', style: kBody),
                        const SizedBox(height: 4),
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
