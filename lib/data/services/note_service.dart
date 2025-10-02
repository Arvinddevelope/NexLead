import 'package:nextlead/data/models/note_model.dart';
import 'airtable_service.dart';

class NoteService {
  final AirtableService _airtableService;
  static const String _tableName = 'Notes'; // Airtable table name

  NoteService(this._airtableService);

  /// Get all notes for a lead
  Future<List<Note>> getNotesByLeadId(String leadId) async {
    try {
      final records = await _airtableService.getRecords(_tableName);
      final leadNotes = records.where((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        // In Airtable, the field is called "Lead", not "Lead ID"
        final relatedLeads = fields['Lead'] as List<dynamic>?;
        return relatedLeads != null &&
            relatedLeads.isNotEmpty &&
            relatedLeads.first == leadId;
      }).toList();

      return leadNotes.map((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        return Note(
          id: record['id'] as String,
          leadId: _getFirstLinkedRecordId(fields['Lead']), // Use "Lead" field
          content: fields['Note'] as String? ?? '', // Use "Note" field
          createdAt: DateTime.parse(fields['Created Date'] as String? ??
              DateTime.now().toIso8601String()),
          updatedAt: DateTime.now(), // Airtable handles this automatically
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  /// Get note by ID
  Future<Note> getNoteById(String id) async {
    try {
      final record = await _airtableService.getRecord(_tableName, id);
      final fields = record['fields'] as Map<String, dynamic>;

      return Note(
        id: record['id'] as String,
        leadId: _getFirstLinkedRecordId(fields['Lead']), // Use "Lead" field
        content: fields['Note'] as String? ?? '', // Use "Note" field
        createdAt: DateTime.parse(fields['Created Date'] as String? ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.now(), // Airtable handles this automatically
      );
    } catch (e) {
      throw Exception('Failed to fetch note: $e');
    }
  }

  /// Create a new note
  Future<Note> createNote(Note note) async {
    try {
      // Map our model fields to Airtable field names
      final fields = <String, dynamic>{};

      // For linked record fields, we need to send an array of record IDs
      if (note.leadId.isNotEmpty) {
        fields['Lead'] = [note.leadId]; // Use "Lead" field
      }

      fields['Note'] = note.content; // Use "Note" field

      final record = await _airtableService.createRecord(_tableName, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Note(
        id: record['id'] as String,
        leadId:
            _getFirstLinkedRecordId(recordFields['Lead']), // Use "Lead" field
        content: recordFields['Note'] as String? ?? '', // Use "Note" field
        createdAt: DateTime.parse(recordFields['Created Date'] as String? ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.now(), // Airtable handles this automatically
      );
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  /// Update an existing note
  Future<Note> updateNote(Note note) async {
    try {
      // Map our model fields to Airtable field names
      final fields = <String, dynamic>{};

      // For linked record fields, we need to send an array of record IDs
      if (note.leadId.isNotEmpty) {
        fields['Lead'] = [note.leadId]; // Use "Lead" field
      }

      fields['Note'] = note.content; // Use "Note" field

      final record =
          await _airtableService.updateRecord(_tableName, note.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Note(
        id: record['id'] as String,
        leadId:
            _getFirstLinkedRecordId(recordFields['Lead']), // Use "Lead" field
        content: recordFields['Note'] as String? ?? '', // Use "Note" field
        createdAt: DateTime.parse(recordFields['Created Date'] as String? ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.now(), // Airtable handles this automatically
      );
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    try {
      await _airtableService.deleteRecord(_tableName, id);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
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
}
