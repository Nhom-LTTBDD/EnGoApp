// lib/core/extensions/color_extensions.dart
// Extensions for color handling và theme utilities

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Extensions cho Color class
extension ColorExtensions on Color {
  /// Tạo MaterialColor từ Color
  MaterialColor toMaterialColor() {
    Map<int, Color> colorMap = {
      50: withOpacity(0.1),
      100: withOpacity(0.2),
      200: withOpacity(0.3),
      300: withOpacity(0.4),
      400: withOpacity(0.6),
      500: this,
      600: withOpacity(0.8),
      700: withOpacity(0.9),
      800: withOpacity(0.95),
      900: withOpacity(1.0),
    };
    
    return MaterialColor(value, colorMap);
  }

  /// Lighten màu
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final hslLightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLightened.toColor();
  }

  /// Darken màu
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final hslDarkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDarkened.toColor();
  }

  /// Check if color is light
  bool get isLight {
    final double relativeLuminance = computeLuminance();
    return relativeLuminance > 0.5;
  }

  /// Check if color is dark
  bool get isDark => !isLight;

  /// Get contrasting text color
  Color get contrastingTextColor => isLight ? Colors.black : Colors.white;
}

/// Extensions cho ThemeData
extension ThemeDataExtensions on ThemeData {
  /// Check if theme is dark
  bool get isDark => brightness == Brightness.dark;

  /// Check if theme is light
  bool get isLight => brightness == Brightness.light;

  /// Get primary container color
  Color get primaryContainer => colorScheme.primaryContainer;

  /// Get surface variant color
  Color get surfaceVariant => colorScheme.surfaceVariant;
}

/// Extensions cho BuildContext để easy access theme colors
extension BuildContextExtensions on BuildContext {
  /// Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  /// App specific colors
  Color get primaryColor => colorScheme.primary;
  Color get secondaryColor => colorScheme.secondary;
  Color get surfaceColor => colorScheme.surface;
  Color get backgroundColor => colorScheme.background;
  Color get errorColor => colorScheme.error;

  /// Text colors
  Color get primaryTextColor => colorScheme.onSurface;
  Color get secondaryTextColor => colorScheme.onSurface.withOpacity(0.6);
  Color get disabledTextColor => colorScheme.onSurface.withOpacity(0.38);

  /// MediaQuery shortcuts
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  
  /// Check screen size categories
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  bool get isLargeScreen => screenWidth >= 1200;
}

/// Color palette helper
class AppColorPalette {
  AppColorPalette._();

  /// Status colors
  static const List<Color> statusColors = [
    kSuccessColor,
    kWarningColor,
    kDanger,
    kAccentColor,
  ];

  /// Primary gradient colors
  static const List<Color> primaryGradient = [
    kPrimaryColor,
    kSecondaryColor,
  ];

  /// Get random status color
  static Color getRandomStatusColor() {
    final index = DateTime.now().millisecond % statusColors.length;
    return statusColors[index];
  }

  /// Get color by index
  static Color getColorByIndex(int index) {
    final colors = statusColors;
    return colors[index % colors.length];
  }

  /// Get complementary color
  static Color getComplementaryColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final complementary = hsl.withHue((hsl.hue + 180) % 360);
    return complementary.toColor();
  }

  /// Generate color variants
  static List<Color> generateColorVariants(Color baseColor, int count) {
    return List.generate(count, (index) {
      final factor = (index + 1) / (count + 1);
      return Color.lerp(baseColor.lighten(0.3), baseColor.darken(0.3), factor)!;
    });
  }
}

/// Theme utilities
class ThemeUtils {
  ThemeUtils._();

  /// Create dynamic color scheme based on primary color
  static ColorScheme createColorScheme({
    required Color primaryColor,
    Brightness brightness = Brightness.light,
  }) {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );
  }

  /// Create custom theme data
  static ThemeData createThemeData({
    required Color primaryColor,
    Brightness brightness = Brightness.light,
    String? fontFamily,
  }) {
    final colorScheme = createColorScheme(
      primaryColor: primaryColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: primaryColor.contrastingTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
