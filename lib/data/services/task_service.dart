import 'package:nextlead/data/models/task_model.dart';
import 'airtable_service.dart';

class TaskService {
  final AirtableService _airtableService;
  static const String _tableName = 'Tasks'; // Airtable table name

  TaskService(this._airtableService);

  /// Get all tasks for a lead
  Future<List<Task>> getTasksByLeadId(String leadId) async {
    try {
      final records = await _airtableService.getRecords(_tableName);
      final leadTasks = records.where((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        // In Airtable, the field is called "Related Lead", not "Lead ID"
        final relatedLeads = fields['Related Lead'] as List<dynamic>?;
        return relatedLeads != null &&
            relatedLeads.isNotEmpty &&
            relatedLeads.first == leadId;
      }).toList();

      return leadTasks.map((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        return Task(
          id: record['id'] as String,
          leadId: _getFirstLinkedRecordId(
              fields['Related Lead']), // Use "Related Lead" field
          title: fields['Task Name'] as String? ?? '', // Use "Task Name" field
          description: fields['Description'] as String? ?? '',
          dueDate: _parseDateTime(fields['Due Date']), // Use "Due Date" field
          isCompleted:
              _getStatusAsBoolean(fields['Status']), // Use "Status" field
          createdAt: DateTime.parse(fields['Created Date'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: DateTime.now(), // Airtable handles this automatically
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  /// Get all tasks (for dashboard)
  Future<List<Task>> getAllTasks() async {
    try {
      final records = await _airtableService.getRecords(_tableName);

      return records.map((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        return Task(
          id: record['id'] as String,
          leadId: _getFirstLinkedRecordId(
              fields['Related Lead']), // Use "Related Lead" field
          title: fields['Task Name'] as String? ?? '', // Use "Task Name" field
          description: fields['Description'] as String? ?? '',
          dueDate: _parseDateTime(fields['Due Date']), // Use "Due Date" field
          isCompleted:
              _getStatusAsBoolean(fields['Status']), // Use "Status" field
          createdAt: DateTime.parse(fields['Created Date'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: DateTime.now(), // Airtable handles this automatically
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  /// Get task by ID
  Future<Task> getTaskById(String id) async {
    try {
      final record = await _airtableService.getRecord(_tableName, id);
      final fields = record['fields'] as Map<String, dynamic>;

      return Task(
        id: record['id'] as String,
        leadId: _getFirstLinkedRecordId(
            fields['Related Lead']), // Use "Related Lead" field
        title: fields['Task Name'] as String? ?? '', // Use "Task Name" field
        description: fields['Description'] as String? ?? '',
        dueDate: _parseDateTime(fields['Due Date']), // Use "Due Date" field
        isCompleted:
            _getStatusAsBoolean(fields['Status']), // Use "Status" field
        createdAt: DateTime.parse(fields['Created Date'] as String? ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.now(), // Airtable handles this automatically
      );
    } catch (e) {
      throw Exception('Failed to fetch task: $e');
    }
  }

  /// Create a new task
  Future<Task> createTask(Task task) async {
    try {
      // Map our model fields to Airtable field names
      final fields = <String, dynamic>{};

      // For linked record fields, we need to send an array of record IDs
      if (task.leadId.isNotEmpty) {
        fields['Related Lead'] = [task.leadId]; // Use "Related Lead" field
      }

      fields['Task Name'] = task.title; // Use "Task Name" field
      fields['Description'] = task.description;
      fields['Due Date'] =
          _formatDateTimeForAirtable(task.dueDate); // Use "Due Date" field

      // Map boolean to status field values
      fields['Status'] =
          task.isCompleted ? 'Done' : 'Todo'; // Use "Status" field

      final record = await _airtableService.createRecord(_tableName, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Task(
        id: record['id'] as String,
        leadId: _getFirstLinkedRecordId(
            recordFields['Related Lead']), // Use "Related Lead" field
        title:
            recordFields['Task Name'] as String? ?? '', // Use "Task Name" field
        description: recordFields['Description'] as String? ?? '',
        dueDate:
            _parseDateTime(recordFields['Due Date']), // Use "Due Date" field
        isCompleted:
            _getStatusAsBoolean(recordFields['Status']), // Use "Status" field
        createdAt: DateTime.parse(recordFields['Created Date'] as String? ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.now(), // Airtable handles this automatically
      );
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  /// Update an existing task
  Future<Task> updateTask(Task task) async {
    try {
      // Map our model fields to Airtable field names
      final fields = <String, dynamic>{};

      // For linked record fields, we need to send an array of record IDs
      if (task.leadId.isNotEmpty) {
        fields['Related Lead'] = [task.leadId]; // Use "Related Lead" field
      }

      fields['Task Name'] = task.title; // Use "Task Name" field
      fields['Description'] = task.description;
      fields['Due Date'] =
          _formatDateTimeForAirtable(task.dueDate); // Use "Due Date" field

      // Map boolean to status field values
      fields['Status'] =
          task.isCompleted ? 'Done' : 'Todo'; // Use "Status" field

      final record =
          await _airtableService.updateRecord(_tableName, task.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Task(
        id: record['id'] as String,
        leadId: _getFirstLinkedRecordId(
            recordFields['Related Lead']), // Use "Related Lead" field
        title:
            recordFields['Task Name'] as String? ?? '', // Use "Task Name" field
        description: recordFields['Description'] as String? ?? '',
        dueDate:
            _parseDateTime(recordFields['Due Date']), // Use "Due Date" field
        isCompleted:
            _getStatusAsBoolean(recordFields['Status']), // Use "Status" field
        createdAt: DateTime.parse(recordFields['Created Date'] as String? ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.now(), // Airtable handles this automatically
      );
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _airtableService.deleteRecord(_tableName, id);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Helper method to extract the first record ID from a linked record field
  String _getFirstLinkedRecordId(dynamic linkedRecordField) {
    if (linkedRecordField == null) return '';
    if (linkedRecordField is List) {
      return linkedRecordField.isNotEmpty
          ? linkedRecordField.first.toString()
          : '';
    }
    return linkedRecordField.toString();
  }

  /// Helper method to parse date/time from Airtable
  DateTime _parseDateTime(dynamic dateTimeField) {
    if (dateTimeField == null) return DateTime.now();
    if (dateTimeField is String) {
      try {
        return DateTime.parse(dateTimeField);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Helper method to format date/time for Airtable
  String _formatDateTimeForAirtable(DateTime dateTime) {
    // Airtable expects ISO 8601 format for datetime fields
    return dateTime.toIso8601String();
  }

  /// Helper method to convert Airtable status to boolean
  bool _getStatusAsBoolean(dynamic statusField) {
    if (statusField == null) return false;
    if (statusField is String) {
      return statusField.toLowerCase() == 'done';
    }
    return false;
  }
}
