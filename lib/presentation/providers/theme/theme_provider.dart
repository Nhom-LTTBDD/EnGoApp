// lib/presentation/providers/theme/theme_provider.dart
// Provider quản lý theme mode (light/dark)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  bool _isDarkMode = false;
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  /// Load theme từ SharedPreferences khi app khởi động
  Future<void> loadTheme() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle giữa light và dark mode
  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error setting theme: $e');
      _isDarkMode = !isDark;
      notifyListeners();
    }
  }
}
