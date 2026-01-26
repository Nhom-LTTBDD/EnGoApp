// lib/presentation/providers/theme/theme_provider.dart
// Provider quản lý theme mode (light/dark)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  late bool _isDarkMode;

  ThemeProvider(this._prefs) {
    // Load theme synchronously from already-initialized SharedPreferences
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
  }

  bool get isDarkMode => _isDarkMode;

  /// Toggle giữa light và dark mode
  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      notifyListeners();

      await _prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme: $e');
      // Revert nếu lỗi
      _isDarkMode = !_isDarkMode;
      notifyListeners();
    }
  }

  /// Set theme mode cụ thể
  Future<void> setThemeMode(bool isDark) async {
    if (_isDarkMode == isDark) return;

    try {
      _isDarkMode = isDark;
      notifyListeners();

      await _prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error setting theme: $e');
      _isDarkMode = !isDark;
      notifyListeners();
    }
  }
}
