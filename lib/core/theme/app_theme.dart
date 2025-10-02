import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';

  bool _isDarkMode = false;
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  ThemeData get currentTheme =>
      _isDarkMode ? DarkTheme.darkTheme : LightTheme.lightTheme;

  AppTheme() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
}
