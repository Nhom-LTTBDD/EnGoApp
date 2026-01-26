// lib/presentation/pages/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/auth_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';
import '../../widgets/common/app_button.dart';

// Top-level function for password strength calculation (for compute isolate)
Map<String, dynamic> _calculatePasswordStrength(String password) {
  double strength = 0.0;

  if (password.isEmpty) {
    return {'strength': 0.0, 'text': '', 'color': Colors.grey.value};
  }

  // Length check
  if (password.length >= 8) strength += 0.3;
  if (password.length >= 12) strength += 0.1;

  // Character variety checks
  if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
  if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
  if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
  if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

  String strengthText;
  int strengthColor;

  if (strength <= 0.3) {
    strengthText = 'Yếu';
    strengthColor = kDanger.value;
  } else if (strength <= 0.6) {
    strengthText = 'Trung bình';
    strengthColor = Colors.orange.value;
  } else {
    strengthText = 'Mạnh';
    strengthColor = Colors.green.value;
  }

  return {
    'strength': strength.clamp(0.0, 1.0),
    'text': strengthText,
    'color': strengthColor,
  };
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  AuthState? _previousAuthState;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() async {
    final password = _passwordController.text;

    // Run computation in isolate to avoid blocking main thread
    final result = await compute(_calculatePasswordStrength, password);

    if (!mounted) return;

    setState(() {
      _passwordStrength = result['strength'];
      _passwordStrengthText = result['text'];
      _passwordStrengthColor = Color(result['color']);
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthProvider>().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  /// Xử lý navigation và errors khi state thay đổi
  void _handleAuthStateChange(BuildContext context, AuthState authState) {
    // Chỉ handle khi state thực sự thay đổi
    if (_previousAuthState == authState) return;
    _previousAuthState = authState;

    if (authState is Authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      });
    } else if (authState is AuthError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.message),
              backgroundColor: kDanger,
              duration: const Duration(seconds: 2),
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
      title: 'Đăng ký',
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final authState = authProvider.state;
          final isLoading = authState is AuthLoading;

          // Handle state changes
          _handleAuthStateChange(context, authState);

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
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Nhập họ và tên đầy đủ',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),

                      prefixIcon: Icon(
                        Icons.person_outlined,
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
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'vd: name@domain.com',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
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
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Ít nhất 6 ký tự',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
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

                  // Password Strength Indicator
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.grey.shade200,
                          color: _passwordStrengthColor,
                          minHeight: 4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Độ mạnh: $_passwordStrengthText',
                          style: TextStyle(
                            fontSize: 12,
                            color: _passwordStrengthColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    enabled: !isLoading,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleRegister(),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Nhập lại mật khẩu',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
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
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  Opacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: AppButton(
                        text: isLoading ? 'Đang đăng ký...' : 'Đăng ký',
                        variant: AppButtonVariant.accent,
                        size: AppButtonSize.large,
                        onPressed: isLoading ? null : _handleRegister,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pushNamed(context, AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        text: 'Đã có tài khoản? ',
                        style: kBody,
                        children: [
                          TextSpan(text: 'Đăng nhập', style: kBodyEmphasized),
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
