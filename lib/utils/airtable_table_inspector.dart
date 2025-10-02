import 'package:nextlead/data/services/airtable_service.dart';

class AirtableTableInspector {
  final AirtableService _airtableService;

  AirtableTableInspector(this._airtableService);

  /// Get the structure of a table by examining the first record
  Future<Map<String, dynamic>> getTableStructure(String tableName) async {
    try {
      final records = await _airtableService.getRecords(tableName);
      if (records.isEmpty) {
        return {'error': 'No records found in table'};
      }

      final firstRecord = records[0];
      final fields = firstRecord['fields'] as Map<String, dynamic>;

      final structure = <String, dynamic>{};
      fields.forEach((key, value) {
        structure[key] = {
          'type': value.runtimeType.toString(),
          'sample_value': value.toString(),
          'is_linked_record': _isLikelyLinkedRecordField(value),
        };
      });

      return {
        'table_name': tableName,
        'field_count': structure.length,
        'fields': structure,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// List all available tables in the base
  Future<List<String>> listTables() async {
    // This is a simplified version - in a real implementation you might
    // want to use the Airtable API's table listing endpoint
    return [
      'Leads',
      'Users',
      'Notes',
      'Tasks',
      'Settings',
    ];
  }

  /// Check if a field value looks like a linked record field
  bool _isLikelyLinkedRecordField(dynamic value) {
    if (value is List) {
      // If it's already a list, check if it contains record-like objects
      if (value.isNotEmpty) {
        final firstItem = value[0];
        if (firstItem is Map && firstItem.containsKey('id')) {
          return true;
        }
        if (firstItem is String &&
            firstItem.startsWith('rec') &&
            firstItem.length > 10) {
          return true;
        }
      }
      return false;
    }

    // If it's a string that looks like a record ID, it might be a single linked record
    // that should be in an array format
    if (value is String && value.startsWith('rec') && value.length > 10) {
      return true;
    }

    return false;
  }

  /// Get information about potential linked record fields
  Future<List<String>> getPotentialLinkedRecordFields(String tableName) async {
    try {
      final structure = await getTableStructure(tableName);
      if (structure.containsKey('error')) {
        return [];
      }

      final fields = structure['fields'] as Map<String, dynamic>;
      final linkedFields = <String>[];

      fields.forEach((fieldName, fieldInfo) {
        if (fieldInfo['is_linked_record'] == true) {
          linkedFields.add(fieldName);
        }
      });

      return linkedFields;
    } catch (e) {
      return [];
    }
  }
}
