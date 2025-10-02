import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/settings_service.dart';

void main() async {
  print('Testing Settings Functionality...');

  try {
    // Create services
    final airtableService = AirtableService();
    final settingsService = SettingsService(airtableService);

    // Test 1: Get current settings
    print('Test 1: Getting current settings...');
    final currentSettings = await settingsService.getSettings();
    print('✅ Current settings retrieved successfully!');
    print('Settings ID: ${currentSettings.id}');
    print('Dark Mode: ${currentSettings.isDarkMode}');
    print('Notifications Enabled: ${currentSettings.notificationsEnabled}');
    print('User Name: ${currentSettings.userName}');
    print('User Email: ${currentSettings.userEmail}');

    // Test 2: Update settings
    final updatedSettings = currentSettings.copyWith(
      isDarkMode: !currentSettings.isDarkMode,
      notificationsEnabled: !currentSettings.notificationsEnabled,
      userName: 'Test User',
      userEmail: 'test@example.com',
    );

    print('\nTest 2: Updating settings...');
    final savedSettings = await settingsService.updateSettings(updatedSettings);
    print('✅ Settings updated successfully!');
    print('Updated Dark Mode: ${savedSettings.isDarkMode}');
    print('Updated Notifications: ${savedSettings.notificationsEnabled}');
    print('Updated User Name: ${savedSettings.userName}');
    print('Updated User Email: ${savedSettings.userEmail}');

    // Test 3: Retrieve updated settings
    print('\nTest 3: Retrieving updated settings...');
    final retrievedSettings = await settingsService.getSettings();
    print('✅ Updated settings retrieved successfully!');
    print('Retrieved Dark Mode: ${retrievedSettings.isDarkMode}');
    print('Retrieved Notifications: ${retrievedSettings.notificationsEnabled}');
    print('Retrieved User Name: ${retrievedSettings.userName}');
    print('Retrieved User Email: ${retrievedSettings.userEmail}');

    // Verify that the settings were properly updated
    if (retrievedSettings.isDarkMode == savedSettings.isDarkMode &&
        retrievedSettings.notificationsEnabled ==
            savedSettings.notificationsEnabled &&
        retrievedSettings.userName == savedSettings.userName &&
        retrievedSettings.userEmail == savedSettings.userEmail) {
      print('\n🎉 All settings functionality tests passed!');
    } else {
      print('\n❌ Settings verification failed!');
    }
  } catch (e) {
    print('❌ Error during settings functionality test: $e');
  }
}
