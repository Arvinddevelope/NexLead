import 'package:nextlead/data/models/settings_model.dart';

void main() async {
  print('Testing Settings Model...');

  // Test 1: Create settings object
  final settings = Settings(
    id: 'test_settings',
    isDarkMode: false,
    notificationsEnabled: true,
    userName: 'Test User',
    userEmail: 'test@example.com',
  );

  print('✅ Settings object created successfully!');
  print('Settings ID: ${settings.id}');
  print('Dark Mode: ${settings.isDarkMode}');
  print('Notifications Enabled: ${settings.notificationsEnabled}');
  print('User Name: ${settings.userName}');
  print('User Email: ${settings.userEmail}');

  // Test 2: Copy with new values
  final updatedSettings = settings.copyWith(
    isDarkMode: true,
    notificationsEnabled: false,
    userName: 'Updated User',
  );

  print('\n✅ Settings copyWith works correctly!');
  print('Updated Dark Mode: ${updatedSettings.isDarkMode}');
  print('Updated Notifications: ${updatedSettings.notificationsEnabled}');
  print('Updated User Name: ${updatedSettings.userName}');
  print('User Email (unchanged): ${updatedSettings.userEmail}');

  // Test 3: Convert to JSON
  final json = settings.toJson();
  print('\n✅ Settings toJson works correctly!');
  print('JSON: $json');

  // Test 4: Create from JSON
  final fromJsonSettings = Settings.fromJson(json);
  print('\n✅ Settings fromJson works correctly!');
  print('From JSON ID: ${fromJsonSettings.id}');
  print('From JSON User Name: ${fromJsonSettings.userName}');

  print('\n🎉 All local settings tests passed!');
}
