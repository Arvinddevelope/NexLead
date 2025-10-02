import 'package:nextlead/data/models/settings_model.dart';
import 'package:nextlead/data/services/settings_service.dart';

class SettingsRepository {
  final SettingsService _settingsService;

  SettingsRepository(this._settingsService);

  /// Get app settings
  Future<Settings> getSettings() async {
    return await _settingsService.getSettings();
  }

  /// Update app settings
  Future<Settings> updateSettings(Settings settings) async {
    return await _settingsService.updateSettings(settings);
  }
}
