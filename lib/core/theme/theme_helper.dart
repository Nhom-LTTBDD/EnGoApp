// lib/core/theme/theme_helper.dart
// Helper functions để lấy màu từ theme extension

import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Get AppThemeExtension từ context
AppThemeExtension? getThemeExtension(BuildContext context) {
  return Theme.of(context).extension<AppThemeExtension>();
}

/// Màu text chính (dark: white, light: black)
Color getTextPrimary(BuildContext context) {
  return getThemeExtension(context)?.textPrimary ?? const Color(0xFF212121);
}

/// Màu text phụ
Color getTextSecondary(BuildContext context) {
  return getThemeExtension(context)?.textSecondary ?? const Color(0xFF424242);
}

/// Màu text mờ nhất
Color getTextThird(BuildContext context) {
  return getThemeExtension(context)?.textThird ?? const Color(0xFF9E9E9E);
}

/// Màu surface (card, container)
Color getSurfaceColor(BuildContext context) {
  return getThemeExtension(context)?.surfaceColor ?? Colors.white;
}

/// Màu background chính
Color getBackgroundColor(BuildContext context) {
  return getThemeExtension(context)?.backgroundColor ?? const Color(0xFFF5F5F5);
}

/// Màu divider/border
Color getDividerColor(BuildContext context) {
  return getThemeExtension(context)?.dividerColor ?? const Color(0xFFE0E0E0);
}

Color getBorderColor(BuildContext context) {
  return getThemeExtension(context)?.borderColor ?? const Color(0xFFBDBDBD);
}

/// Màu card background
Color getCardBackground(BuildContext context) {
  return getThemeExtension(context)?.cardBackground ?? Colors.white;
}

/// Gradient colors cho background
List<Color> getBackgroundGradient(BuildContext context) {
  return getThemeExtension(context)?.backgroundGradientColors ?? 
      [const Color(0xFFFFFFFF), const Color(0xFFB2E0FF)];
}
