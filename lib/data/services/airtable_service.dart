import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nextlead/core/config/airtable_config.dart';

class AirtableService {
  static const String _baseUrl = 'https://api.airtable.com/v0';
  static const String _apiKey = AirtableConfig.apiKey;
  static const String _baseId = AirtableConfig.baseId;

  final http.Client _client = http.Client();

  // Headers for Airtable API requests
  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

  /// Get records from a table
  Future<List<dynamic>> getRecords(String tableName) async {
    final url = '$_baseUrl/$_baseId/$tableName';
    final response = await _client.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['records'] as List<dynamic>;
    } else {
      // Parse error response for more details
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception(
            'Failed to load records: ${response.statusCode} - $errorMessage');
      } catch (e) {
        // If we can't parse the error, throw the original error
        throw Exception(
            'Failed to load records: ${response.statusCode} - ${response.body}');
      }
    }
  }

  /// Get a specific record by ID
  Future<Map<String, dynamic>> getRecord(
      String tableName, String recordId) async {
    final url = '$_baseUrl/$_baseId/$tableName/$recordId';
    final response = await _client.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Parse error response for more details
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception(
            'Failed to load record: ${response.statusCode} - $errorMessage');
      } catch (e) {
        // If we can't parse the error, throw the original error
        throw Exception(
            'Failed to load record: ${response.statusCode} - ${response.body}');
      }
    }
  }

  /// Create a new record
  Future<Map<String, dynamic>> createRecord(
      String tableName, Map<String, dynamic> fields) async {
    final url = '$_baseUrl/$_baseId/$tableName';
    final body = json.encode({'fields': fields});

    final response =
        await _client.post(Uri.parse(url), headers: _headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Parse error response for more details
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception(
            'Failed to create record: ${response.statusCode} - $errorMessage');
      } catch (e) {
        // If we can't parse the error, throw the original error
        throw Exception(
            'Failed to create record: ${response.statusCode} - ${response.body}');
      }
    }
  }

  /// Update an existing record
  Future<Map<String, dynamic>> updateRecord(
      String tableName, String recordId, Map<String, dynamic> fields) async {
    final url = '$_baseUrl/$_baseId/$tableName/$recordId';
    final body = json.encode({'fields': fields});

    final response =
        await _client.patch(Uri.parse(url), headers: _headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Parse error response for more details
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception(
            'Failed to update record: ${response.statusCode} - $errorMessage');
      } catch (e) {
        // If we can't parse the error, throw the original error
        throw Exception(
            'Failed to update record: ${response.statusCode} - ${response.body}');
      }
    }
  }

  /// Delete a record
  Future<void> deleteRecord(String tableName, String recordId) async {
    final url = '$_baseUrl/$_baseId/$tableName/$recordId';
    final response = await _client.delete(Uri.parse(url), headers: _headers);

    if (response.statusCode != 200) {
      // Parse error response for more details
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception(
            'Failed to delete record: ${response.statusCode} - $errorMessage');
      } catch (e) {
        // If we can't parse the error, throw the original error
        throw Exception(
            'Failed to delete record: ${response.statusCode} - ${response.body}');
      }
    }
  }
}
