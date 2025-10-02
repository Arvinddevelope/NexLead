import 'package:flutter/material.dart';
import 'package:nextlead/data/models/settings_model.dart';
import 'package:nextlead/data/repositories/settings_repository.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _settingsRepository;

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = false;
  String _errorMessage = '';

  SettingsProvider(this._settingsRepository) {
    _loadSettings();
  }

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final settings = await _settingsRepository.getSettings();
      _isDarkMode = settings.isDarkMode;
      _notificationsEnabled = settings.notificationsEnabled;
      _userName = settings.userName;
      _userEmail = settings.userEmail;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateProfile(String name, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userName = name;
      _userEmail = email;
      notifyListeners();
      await _saveSettings();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = Settings(
        id: 'app_settings',
        isDarkMode: _isDarkMode,
        notificationsEnabled: _notificationsEnabled,
        userName: _userName,
        userEmail: _userEmail,
      );

      await _settingsRepository.updateSettings(settings);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
}
