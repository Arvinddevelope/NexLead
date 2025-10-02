import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/core/config/airtable_config.dart';

class AirtableDebug {
  static Future<void> testUsersTable() async {
    try {
      final airtableService = AirtableService();

      print('Testing Airtable connection...');
      print('Base ID: ${AirtableConfig.baseId}');
      print('API Key exists: ${AirtableConfig.apiKey.isNotEmpty}');
      print('Users table name: ${AirtableConfig.usersTable}');

      // Test 1: Try to get records from Users table
      print('\n--- Test 1: Checking if Users table exists ---');
      try {
        final records =
            await airtableService.getRecords(AirtableConfig.usersTable);
        print('✅ Users table exists. Found ${records.length} records.');
      } catch (e) {
        print('❌ Error accessing Users table: $e');
      }

      // Test 2: Try to create a simple test record
      print('\n--- Test 2: Testing record creation ---');
      try {
        final testFields = {
          'Name': 'Test User',
          'Email': 'test@example.com',
          'Password': 'test123',
        };

        final result = await airtableService.createRecord(
            AirtableConfig.usersTable, testFields);
        print('✅ Successfully created test record: ${result['id']}');

        // Clean up - delete the test record
        try {
          await airtableService.deleteRecord(
              AirtableConfig.usersTable, result['id'] as String);
          print('✅ Cleaned up test record');
        } catch (e) {
          print('⚠️  Could not clean up test record: $e');
        }
      } catch (e) {
        print('❌ Error creating test record: $e');
      }

      print('\n--- Debug Complete ---');
    } catch (e) {
      print('❌ Debug test failed: $e');
    }
  }
}
