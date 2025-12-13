// lib/presentation/widgets/app_button.dart
// Widget nút bấm chuẩn cho ứng dụng EnGo App.
import 'package:flutter/material.dart';
import 'package:en_go_app/core/constants/app_colors.dart';

/// Button variants
enum AppButtonVariant {
  primary,
  success,
  danger,
  ghost,
  accent,
  borderSuccess,
  borderWarning,
  borderSpecial,
}

/// Button sizes
enum AppButtonSize { small, medium, large, xLarge }

/// cài đặt kiểu dáng nút bấm
class AppButtonStyle {
  final Color backgroundColor;
  final LinearGradient? backgroundGradient;
  final Color textColor;
  final List<BoxShadow>? shadow;
  final double borderRadius;
  final EdgeInsets padding;
  final double height;
  final Color? borderColor;
  final double? borderWidth;

  const AppButtonStyle({
    required this.backgroundColor,
    this.backgroundGradient,
    required this.textColor,
    required this.padding,
    required this.height,
    this.shadow,
    this.borderRadius = 12,
    this.borderColor,
    this.borderWidth = 1,
  });
}

/// kích thước nút bấm theo size
final Map<AppButtonSize, double> _heightBySize = {
  AppButtonSize.small: 36,
  AppButtonSize.medium: 44,
  AppButtonSize.large: 52,
  AppButtonSize.xLarge: 60,
};

/// cài đặt kiểu dáng cho từng variant nút bấm
final Map<AppButtonVariant, AppButtonStyle> _buttonStyles = {
  AppButtonVariant.primary: AppButtonStyle(
    backgroundColor: kPrimaryButtonColor,
    textColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
    shadow: [
      BoxShadow(
        color: kSecondaryColor.withOpacity(0.4),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  ),

  AppButtonVariant.success: AppButtonStyle(
    backgroundColor: kSuccessButtonColor,
    textColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
    shadow: [
      BoxShadow(
        color: kSuccess.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),

  AppButtonVariant.danger: AppButtonStyle(
    backgroundColor: Colors.red,
    textColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
    shadow: [
      BoxShadow(
        color: Colors.redAccent.withOpacity(0.4),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  ),

  AppButtonVariant.ghost: AppButtonStyle(
    backgroundColor: Colors.transparent,
    textColor: Colors.green,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
  ),
  AppButtonVariant.accent: AppButtonStyle(
    backgroundColor: Colors.transparent,
    backgroundGradient: kPrimaryButtonGradient,
    textColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
    shadow: [
      BoxShadow(color: kSecondaryColor, blurRadius: 8, offset: Offset(0, 3)),
    ],
  ),
  AppButtonVariant.borderSuccess: AppButtonStyle(
    backgroundColor: Colors.white,
    textColor: kSuccess,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
    borderColor: kSuccess,
    borderWidth: 3,
    shadow: [
      BoxShadow(
        color: kSuccess.withOpacity(0.4),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  AppButtonVariant.borderWarning: AppButtonStyle(
    backgroundColor: Colors.white,
    textColor: kWarning,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
    borderColor: kWarning,
    borderWidth: 3,
    shadow: [
      BoxShadow(
        color: kWarning.withOpacity(0.4),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  AppButtonVariant.borderSpecial: AppButtonStyle(
    backgroundColor: Colors.white,
    textColor: kSpecial,
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 48,
    borderColor: kSpecial,
    borderWidth: 3,
    shadow: [
      BoxShadow(
        color: kSpecial.withOpacity(0.4),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
};

/// MAIN BUTTON WIDGET
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _buttonStyles[variant]!;
    final height = _heightBySize[size]!;

    return Container(
      width: isFullWidth ? double.infinity : 300,
      height: height,
      decoration: BoxDecoration(
        gradient: config.backgroundGradient,
        boxShadow: config.shadow,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: config.borderColor != null
            ? Border.all(color: config.borderColor!, width: config.borderWidth!)
            : null,
        color: config.backgroundGradient == null
            ? config.backgroundColor
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.backgroundGradient != null
              ? Colors.transparent
              : config.backgroundColor,

          foregroundColor: config.textColor,
          padding: config.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
