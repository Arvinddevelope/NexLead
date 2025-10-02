import 'dart:io';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/core/config/airtable_config.dart';

void main() async {
  print('Testing Airtable Service with Error Handling...');

  try {
    // Test basic internet connectivity first
    print('1. Testing basic internet connectivity...');
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('✅ Internet connection is available');
    }
  } on SocketException catch (e) {
    print('❌ No internet connection: $e');
    return;
  } catch (e) {
    print('❌ Error checking internet connectivity: $e');
    return;
  }

  try {
    // Test Airtable service initialization
    print('\n2. Testing Airtable service initialization...');
    final airtableService = AirtableService();
    print('✅ Airtable service initialized successfully');

    // Test getting records from Leads table
    print('\n3. Testing Airtable API connectivity with Leads table...');
    final leads = await airtableService.getRecords(AirtableConfig.leadsTable);
    print('✅ Successfully retrieved ${leads.length} leads from Airtable');

    // Test getting records from Settings table
    print('\n4. Testing Airtable API connectivity with Settings table...');
    final settings =
        await airtableService.getRecords(AirtableConfig.settingsTable);
    print(
        '✅ Successfully retrieved ${settings.length} settings records from Airtable');

    print('\n🎉 All Airtable service tests passed!');
  } on SocketException catch (e) {
    print('❌ Network error connecting to Airtable: $e');
    print('Please check:');
    print('  1. Internet connection');
    print('  2. Firewall settings');
    print('  3. Network security configuration');
    print('  4. Airtable API key validity');
  } on Exception catch (e) {
    if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
      print('❌ Airtable API authentication failed');
      print('Please check your Airtable API key in airtable_config.dart');
    } else if (e.toString().contains('404') ||
        e.toString().contains('NOT_FOUND')) {
      print('❌ Airtable base or table not found');
      print(
          'Please check your Airtable base ID and table names in airtable_config.dart');
    } else {
      print('❌ Error with Airtable service: $e');
    }
  } catch (e) {
    print('❌ Unexpected error: $e');
  }
}
