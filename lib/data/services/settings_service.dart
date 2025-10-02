import 'package:nextlead/data/models/settings_model.dart';
import 'airtable_service.dart';

class SettingsService {
  final AirtableService _airtableService;
  static const String _tableName = 'Settings'; // Airtable table name
  static const String _settingsRecordId =
      'app_settings'; // Fixed record ID for app settings

  SettingsService(this._airtableService);

  /// Get app settings
  Future<Settings> getSettings() async {
    try {
      final record =
          await _airtableService.getRecord(_tableName, _settingsRecordId);
      final fields = record['fields'] as Map<String, dynamic>;

      return Settings(
        id: record['id'] as String,
        isDarkMode: fields['Dark Mode'] as bool? ?? false,
        notificationsEnabled: fields['Notifications'] as bool? ?? true,
        userName: fields['User Name'] as String? ?? '',
        userEmail: fields['User Email'] as String? ?? '',
      );
    } catch (e) {
      // If settings record doesn't exist, return default settings
      return Settings(
        id: _settingsRecordId,
        isDarkMode: false,
        notificationsEnabled: true,
        userName: '',
        userEmail: '',
      );
    }
  }

  /// Update app settings
  Future<Settings> updateSettings(Settings settings) async {
    try {
      final fields = {
        'Dark Mode': settings.isDarkMode,
        'Notifications': settings.notificationsEnabled,
        'User Name': settings.userName,
        'User Email': settings.userEmail,
      };

      final record =
          await _airtableService.updateRecord(_tableName, settings.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Settings(
        id: record['id'] as String,
        isDarkMode: recordFields['Dark Mode'] as bool? ?? false,
        notificationsEnabled: recordFields['Notifications'] as bool? ?? true,
        userName: recordFields['User Name'] as String? ?? '',
        userEmail: recordFields['User Email'] as String? ?? '',
      );
    } catch (e) {
      // If update fails, try to create the settings record
      try {
        final fields = {
          'Dark Mode': settings.isDarkMode,
          'Notifications': settings.notificationsEnabled,
          'User Name': settings.userName,
          'User Email': settings.userEmail,
        };

        final record = await _airtableService.createRecord(_tableName, fields);
        final recordFields = record['fields'] as Map<String, dynamic>;

        return Settings(
          id: record['id'] as String,
          isDarkMode: recordFields['Dark Mode'] as bool? ?? false,
          notificationsEnabled: recordFields['Notifications'] as bool? ?? true,
          userName: recordFields['User Name'] as String? ?? '',
          userEmail: recordFields['User Email'] as String? ?? '',
        );
      } catch (createError) {
        throw Exception('Failed to update or create settings: $e');
      }
    }
  }
}
