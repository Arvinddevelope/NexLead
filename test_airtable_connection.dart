import 'dart:convert';
import 'package:http/http.dart' as http;

// Test Airtable connection directly
Future<void> testAirtableConnection() async {
  const apiKey =
      'patCoPkzMRVP8JhhS.e4e18a3156fe256e698e2c1a4db6aa82398e353b25be2638e4446e7d47233305';
  const baseId = 'appYl1bCmKls6EZ6t';
  const tableName = 'Users';
  const baseUrl = 'https://api.airtable.com/v0';

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  print('Testing Airtable connection...');
  print('Base ID: $baseId');
  print('Table Name: $tableName');

  // Test 1: List records to see if table exists
  print('\n--- Test 1: Checking if table exists ---');
  try {
    const url = '$baseUrl/$baseId/$tableName';
    final response = await http.get(Uri.parse(url), headers: headers);

    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(
          '✅ Successfully connected to table. Found ${data['records']?.length ?? 0} records.');
      if (data['records'] != null && data['records'].isNotEmpty) {
        print('First record fields: ${data['records'][0]['fields']}');
      }
    } else {
      print('❌ Error: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }

  // Test 2: Try to create a record
  print('\n--- Test 2: Testing record creation ---');
  try {
    const url = '$baseUrl/$baseId/$tableName';
    final body = json.encode({
      'fields': {
        'Name': 'Test User',
        'Email': 'test@example.com',
        'Password': 'test123',
      }
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Successfully created record: ${data['id']}');
      print('Record fields: ${data['fields']}');

      // Clean up
      try {
        final deleteUrl = '$baseUrl/$baseId/$tableName/${data['id']}';
        final deleteResponse =
            await http.delete(Uri.parse(deleteUrl), headers: headers);
        if (deleteResponse.statusCode == 200) {
          print('✅ Cleaned up test record');
        } else {
          print(
              '⚠️  Could not clean up test record: ${deleteResponse.statusCode}');
        }
      } catch (e) {
        print('⚠️  Error cleaning up: $e');
      }
    } else {
      print('❌ Error creating record: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Try to parse error details
      try {
        final errorData = json.decode(response.body);
        print('Error details: $errorData');
      } catch (e) {
        print('Could not parse error response');
      }
    }
  } catch (e) {
    print('❌ Exception: $e');
  }

  print('\n--- Test Complete ---');
}

void main() async {
  await testAirtableConnection();
}
