import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey =
      'patCoPkzMRVP8JhhS.e4e18a3156fe256e698e2c1a4db6aa82398e353b25be2638e4446e7d47233305';
  const baseId = 'appYl1bCmKls6EZ6t';

  const url = 'https://api.airtable.com/v0/meta/bases/$baseId/tables';
  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Find the Leads table
      final leadsTable = data['tables'].firstWhere(
        (table) => table['name'] == 'Leads',
        orElse: () => null,
      );

      if (leadsTable != null) {
        print('Leads Table Fields:');
        for (var field in leadsTable['fields']) {
          print('- ${field['name']} (${field['type']})');
          // Print select options if available
          if (field['type'] == 'singleSelect' && field['options'] != null) {
            print('  Options: ${field['options']['choices']}');
          }
        }
      } else {
        print('Leads table not found');
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
