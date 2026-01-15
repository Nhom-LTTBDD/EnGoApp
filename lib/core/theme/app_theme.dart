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
    iconTheme: const IconThemeData(color: kPrimaryColor), // Extension colors
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        backgroundGradientColors: [Color(0xFFFFFFFF), Color(0xFFB2E0FF)],
        surfaceOpacity: 0.8,
        shimmerBaseColor: Color(0xFFE0E0E0),
        shimmerHighlightColor: Color(0xFFF5F5F5),
        cardBackground: Colors.white,
        textPrimary: Color(0xFF212121),
        textSecondary: Color(0xFF424242),
        textThird: Color(0xFF9E9E9E),
        surfaceColor: Colors.white,
        backgroundColor: Color(0xFFF5F5F5),
        dividerColor: Color(0xFFE0E0E0),
        borderColor: Color(0xFFBDBDBD),
      ),
    ],
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4A90E2),
    scaffoldBackgroundColor: const Color(0xFF1c1c1d),
    cardColor: const Color(0xFF252728),
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
    iconTheme: const IconThemeData(
      color: Color(0xFF4A90E2),
    ), // Extension colors
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(
        backgroundGradientColors: [Color(0xFF121212), Color(0xFF1E3A52)],
        surfaceOpacity: 0.9,
        shimmerBaseColor: Color(0xFF2C2C2C),
        shimmerHighlightColor: Color(0xFF3A3A3A),
        cardBackground: Color(0xFF2C2C2C),
        textPrimary: Color(0xFFE0E0E0),
        textSecondary: Color(0xFFB0B0B0),
        textThird: Color(0xFF757575),
        surfaceColor: Color(0xFF1E1E1E),
        backgroundColor: Color(0xFF121212),
        dividerColor: Color(0xFF424242),
        borderColor: Color(0xFF616161),
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

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textThird;

  // UI colors
  final Color surfaceColor;
  final Color backgroundColor;
  final Color dividerColor;
  final Color borderColor;

  const AppThemeExtension({
    required this.backgroundGradientColors,
    required this.surfaceOpacity,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textThird,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.dividerColor,
    required this.borderColor,
  });
  @override
  AppThemeExtension copyWith({
    List<Color>? backgroundGradientColors,
    double? surfaceOpacity,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    Color? cardBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textThird,
    Color? surfaceColor,
    Color? backgroundColor,
    Color? dividerColor,
    Color? borderColor,
  }) {
    return AppThemeExtension(
      backgroundGradientColors:
          backgroundGradientColors ?? this.backgroundGradientColors,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor:
          shimmerHighlightColor ?? this.shimmerHighlightColor,
      cardBackground: cardBackground ?? this.cardBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textThird: textThird ?? this.textThird,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      borderColor: borderColor ?? this.borderColor,
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
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textThird: Color.lerp(textThird, other.textThird, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }
}
