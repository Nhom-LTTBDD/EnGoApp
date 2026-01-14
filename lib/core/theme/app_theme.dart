// lib/core/theme/app_theme.dart
// Theme configuration cho light và dark mode
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.grey[300],

    // AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF424242)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF616161)),
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: kPrimaryColor),

    // Extension colors
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        backgroundGradientColors: [Color(0xFFFFFFFF), Color(0xFFB2E0FF)],
        surfaceOpacity: 0.8,
        shimmerBaseColor: Color(0xFFE0E0E0),
        shimmerHighlightColor: Color(0xFFF5F5F5),
        cardBackground: Colors.white,
      ),
    ],
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4A90E2),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: const Color(0xFF424242),

    // AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0E0E0),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: Color(0xFF4A90E2)),

    // Extension colors
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        backgroundGradientColors: [Color(0xFF121212), Color(0xFF1E3A52)],
        surfaceOpacity: 0.9,
        shimmerBaseColor: Color(0xFF2C2C2C),
        shimmerHighlightColor: Color(0xFF3A3A3A),
        cardBackground: Color(0xFF2C2C2C),
      ),
    ],
  );
}

// Extension để thêm custom colors cho theme
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final List<Color> backgroundGradientColors;
  final double surfaceOpacity;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;
  final Color cardBackground;

  const AppThemeExtension({
    required this.backgroundGradientColors,
    required this.surfaceOpacity,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
    required this.cardBackground,
  });

  @override
  AppThemeExtension copyWith({
    List<Color>? backgroundGradientColors,
    double? surfaceOpacity,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    Color? cardBackground,
  }) {
    return AppThemeExtension(
      backgroundGradientColors:
          backgroundGradientColors ?? this.backgroundGradientColors,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor:
          shimmerHighlightColor ?? this.shimmerHighlightColor,
      cardBackground: cardBackground ?? this.cardBackground,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      backgroundGradientColors: [
        Color.lerp(
          backgroundGradientColors[0],
          other.backgroundGradientColors[0],
          t,
        )!,
        Color.lerp(
          backgroundGradientColors[1],
          other.backgroundGradientColors[1],
          t,
        )!,
      ],
      surfaceOpacity: t < 0.5 ? surfaceOpacity : other.surfaceOpacity,
      shimmerBaseColor: Color.lerp(
        shimmerBaseColor,
        other.shimmerBaseColor,
        t,
      )!,
      shimmerHighlightColor: Color.lerp(
        shimmerHighlightColor,
        other.shimmerHighlightColor,
        t,
      )!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
    );
  }
}
