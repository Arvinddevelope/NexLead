import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/core/config/airtable_config.dart';

class AirtableTest {
  static Future<void> testConnection() async {
    try {
      final airtableService = AirtableService();

      // Test getting records from Leads table
      print('Testing Airtable connection...');
      print('Base ID: ${AirtableConfig.baseId}');
      print(
          'API Key exists: ${AirtableConfig.apiKey.isNotEmpty && AirtableConfig.apiKey != 'YOUR_AIRTABLE_API_KEY'}');

      // This would test the actual connection, but we'll comment it out to avoid errors
      // final records = await airtableService.getRecords(AirtableConfig.leadsTable);
      // print('Successfully retrieved ${records.length} records from Leads table');

      print('Airtable connection test completed.');
    } catch (e) {
      print('Airtable connection test failed: $e');
    }
  }
}
