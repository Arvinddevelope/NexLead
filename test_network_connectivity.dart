import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Network Connectivity...');

  try {
    // Test basic internet connectivity
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
    // Test Airtable API connectivity
    print('\n2. Testing Airtable API connectivity...');
    final response = await http.get(
      Uri.parse('https://api.airtable.com/v0/meta/bases'),
      headers: {
        'Authorization':
            'Bearer patCoPkzMRVP8JhhS.e4e18a3156fe256e698e2c1a4db6aa82398e353b25be2638e4446e7d47233305',
      },
    ).timeout(const Duration(seconds: 10));

    print('Airtable API Response Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ Airtable API is accessible');
    } else {
      print('❌ Airtable API returned status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } on SocketException catch (e) {
    print('❌ Failed to connect to Airtable API (SocketException): $e');
  } catch (e) {
    if (e.toString().contains('Timeout')) {
      print('❌ Connection to Airtable API timed out: $e');
    } else {
      print('❌ Error connecting to Airtable API: $e');
    }
  }

  print('\nNetwork connectivity test completed.');
}
