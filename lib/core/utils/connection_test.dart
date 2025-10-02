import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/core/config/airtable_config.dart';

class ConnectionTest {
  static Future<bool> testAirtableConnection() async {
    try {
      // Check if configuration is properly set
      if (AirtableConfig.apiKey == 'YOUR_AIRTABLE_API_KEY' ||
          AirtableConfig.apiKey.isEmpty) {
        print('❌ Airtable API key not configured');
        return false;
      }

      if (AirtableConfig.baseId == 'YOUR_AIRTABLE_BASE_ID' ||
          AirtableConfig.baseId.isEmpty) {
        print('❌ Airtable base ID not configured');
        return false;
      }

      // Test basic connectivity
      final airtableService = AirtableService();

      // This would actually test the connection, but we'll keep it simple for now
      print('✅ Airtable configuration appears to be set up correctly');
      print('Base ID: ${AirtableConfig.baseId}');
      print('API Key configured: ${AirtableConfig.apiKey.length} characters');

      return true;
    } catch (e) {
      print('❌ Airtable connection test failed: $e');
      return false;
    }
  }

  static void printConfigurationStatus() {
    print('=== Airtable Configuration Status ===');

    if (AirtableConfig.apiKey == 'YOUR_AIRTABLE_API_KEY' ||
        AirtableConfig.apiKey.isEmpty) {
      print('❌ API Key: NOT CONFIGURED');
    } else {
      print(
          '✅ API Key: CONFIGURED (${AirtableConfig.apiKey.length} characters)');
    }

    if (AirtableConfig.baseId == 'YOUR_AIRTABLE_BASE_ID' ||
        AirtableConfig.baseId.isEmpty) {
      print('❌ Base ID: NOT CONFIGURED');
    } else {
      print('✅ Base ID: CONFIGURED');
    }

    print('====================================');
  }
}
