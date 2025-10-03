import 'package:nextlead/data/models/lead_model.dart';
import 'airtable_service.dart';

class LeadService {
  final AirtableService _airtableService;
  static const String _tableName = 'Leads'; // Airtable table name

  LeadService(this._airtableService);

  /// Helper method to safely extract string values from any field type
  String? _getStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) return value.isNotEmpty ? value.first.toString() : null;
    return value.toString();
  }

  /// Helper method to check if a value represents a linked record field
  bool _isLinkedRecordField(String value) {
    // Simple heuristic: if it looks like a record ID (starts with rec), it's likely a linked record
    return value.startsWith('rec');
  }

  /// Get all leads
  Future<List<Lead>> getAllLeads() async {
    try {
      final records = await _airtableService.getRecords(_tableName);
      return records.map((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        return Lead(
          id: record['id'] as String,
          name: _getStringValue(fields['Name']) ?? '',
          email: _getStringValue(fields['Email']) ?? '',
          phone: _getStringValue(fields['Phone']) ?? '',
          company: _getStringValue(fields['Company']) ?? '',
          source: _getStringValue(fields['Source']) ?? '',
          status: _getStringValue(fields['Status']) ?? 'New',
          notes: _getStringValue(fields['Notes']) ?? '',
          createdAt: DateTime.parse(_getStringValue(fields['Created At']) ??
              DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(_getStringValue(fields['Updated At']) ??
              DateTime.now().toIso8601String()),
          nextFollowUp: fields['Next Follow-up'] != null
              ? DateTime.parse(_getStringValue(fields['Next Follow-up'])!)
              : null,
          userId: _getStringValue(
              fields['Lead Owner']), // Correct field name is "Lead Owner"
          contactName:
              _getStringValue(fields['Contact Name']), // Add contactName field
          // Location fields
          latitude: fields['Latitude'] as double?,
          longitude: fields['Longitude'] as double?,
          locationAddress: _getStringValue(fields['Location Address']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  /// Get lead by ID
  Future<Lead> getLeadById(String id) async {
    try {
      final record = await _airtableService.getRecord(_tableName, id);
      final fields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(fields['Name']) ?? '',
        email: _getStringValue(fields['Email']) ?? '',
        phone: _getStringValue(fields['Phone']) ?? '',
        company: _getStringValue(fields['Company']) ?? '',
        source: _getStringValue(fields['Source']) ?? '',
        status: _getStringValue(fields['Status']) ?? 'New',
        notes: _getStringValue(fields['Notes']) ?? '',
        createdAt: DateTime.parse(_getStringValue(fields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(fields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: fields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(fields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            fields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName:
            _getStringValue(fields['Contact Name']), // Add contactName field
        // Location fields
        latitude: fields['Latitude'] as double?,
        longitude: fields['Longitude'] as double?,
        locationAddress: _getStringValue(fields['Location Address']),
      );
    } catch (e) {
      throw Exception('Failed to fetch lead: $e');
    }
  }

  /// Get leads by user ID
  Future<List<Lead>> getLeadsByUserId(String userId) async {
    try {
      final records = await _airtableService.getRecords(_tableName);
      return records.where((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        final recordUserId = _getStringValue(fields['Lead Owner']);
        return recordUserId == userId;
      }).map((record) {
        final fields = record['fields'] as Map<String, dynamic>;
        return Lead(
          id: record['id'] as String,
          name: _getStringValue(fields['Name']) ?? '',
          email: _getStringValue(fields['Email']) ?? '',
          phone: _getStringValue(fields['Phone']) ?? '',
          company: _getStringValue(fields['Company']) ?? '',
          source: _getStringValue(fields['Source']) ?? '',
          status: _getStringValue(fields['Status']) ?? 'New',
          notes: _getStringValue(fields['Notes']) ?? '',
          createdAt: DateTime.parse(_getStringValue(fields['Created At']) ??
              DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(_getStringValue(fields['Updated At']) ??
              DateTime.now().toIso8601String()),
          nextFollowUp: fields['Next Follow-up'] != null
              ? DateTime.parse(_getStringValue(fields['Next Follow-up'])!)
              : null,
          userId: _getStringValue(
              fields['Lead Owner']), // Correct field name is "Lead Owner"
          contactName:
              _getStringValue(fields['Contact Name']), // Add contactName field
          // Location fields
          latitude: fields['Latitude'] as double?,
          longitude: fields['Longitude'] as double?,
          locationAddress: _getStringValue(fields['Location Address']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch leads for user: $e');
    }
  }

  /// Create a new lead
  Future<Lead> createLead(Lead lead) async {
    try {
      // Create a minimal fields object with only the most essential fields
      // This avoids the UNKNOWN_FIELD_NAME error by only sending fields that are most likely to exist
      // Note: Do NOT send computed fields like 'Created At' and 'Updated At'
      final fields = <String, dynamic>{};

      // Always include these basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;

      // For Status field, only send valid options
      if (_isValidStatus(lead.status)) {
        fields['Status'] = lead.status;
      } else {
        // Default to "New" if invalid status
        fields['Status'] = 'New';
      }

      // For Source field, only send valid options
      if (_isValidSource(lead.source)) {
        fields['Source'] = lead.source;
      } else {
        // Default to "Other" if invalid source
        fields['Source'] = 'Other';
      }

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      if (lead.company.isNotEmpty) fields['Company'] = lead.company;

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available (only fields that exist in Airtable)
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send 'Updated At' as it is a computed field in Airtable
      // Airtable will automatically update this value

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record = await _airtableService.createRecord(_tableName, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      // Handle different types of errors
      if (e.toString().contains('UNKNOWN_FIELD_NAME')) {
        // Check if the error is related to the User/Lead Owner field
        if (e.toString().contains('User') ||
            e.toString().contains('Users') ||
            e.toString().contains('Lead Owner')) {
          // Retry without the Lead Owner field
          return _createLeadWithoutUserField(lead);
        } else if (e.toString().contains('Company') ||
            e.toString().contains('{Company}')) {
          // Retry without the Company field
          return _createLeadWithoutCompany(lead);
        }
      } else if (e.toString().contains('INVALID_VALUE_FOR_COLUMN')) {
        // Handle linked record field errors
        return _createLeadWithLinkedRecordHandling(lead);
      } else if (e.toString().contains('INVALID_MULTIPLE_CHOICE_OPTIONS')) {
        // Handle invalid select options by using default values
        return _createLeadWithValidSelectOptions(lead);
      }
      throw Exception('Failed to create lead: $e');
    }
  }

  /// Update an existing lead
  Future<Lead> updateLead(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Always include these basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;

      // For Status field, only send valid options
      if (_isValidStatus(lead.status)) {
        fields['Status'] = lead.status;
      } else {
        // Default to "New" if invalid status
        fields['Status'] = 'New';
      }

      // For Source field, only send valid options
      if (_isValidSource(lead.source)) {
        fields['Source'] = lead.source;
      } else {
        // Default to "Other" if invalid source
        fields['Source'] = 'Other';
      }

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      if (lead.company.isNotEmpty) fields['Company'] = lead.company;

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available (only fields that exist in Airtable)
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send 'Updated At' as it is a computed field in Airtable
      // Airtable will automatically update this value

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record =
          await _airtableService.updateRecord(_tableName, lead.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      // Handle different types of errors
      if (e.toString().contains('UNKNOWN_FIELD_NAME')) {
        // Check if the error is related to the User/Lead Owner field
        if (e.toString().contains('User') ||
            e.toString().contains('Users') ||
            e.toString().contains('Lead Owner')) {
          // Retry without the Lead Owner field
          return _updateLeadWithoutUserField(lead);
        } else if (e.toString().contains('Company') ||
            e.toString().contains('{Company}')) {
          // Retry without the Company field
          return _updateLeadWithoutCompany(lead);
        }
      } else if (e.toString().contains('INVALID_VALUE_FOR_COLUMN')) {
        // Handle linked record field errors
        return _updateLeadWithLinkedRecordHandling(lead);
      } else if (e.toString().contains('INVALID_MULTIPLE_CHOICE_OPTIONS')) {
        // Handle invalid select options by using default values
        return _updateLeadWithValidSelectOptions(lead);
      }
      throw Exception('Failed to update lead: $e');
    }
  }

  /// Delete a lead
  Future<void> deleteLead(String id) async {
    try {
      await _airtableService.deleteRecord(_tableName, id);
    } catch (e) {
      throw Exception('Failed to delete lead: $e');
    }
  }

  /// Create lead without User/Lead Owner field
  Future<Lead> _createLeadWithoutUserField(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Always include these basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      if (lead.company.isNotEmpty) fields['Company'] = lead.company;

      // Add new fields if available (only fields that exist in Airtable)
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record = await _airtableService.createRecord(_tableName, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to create lead even after removing Lead Owner field: $e');
    }
  }

  /// Update lead without User/Lead Owner field
  Future<Lead> _updateLeadWithoutUserField(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Always include these basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      if (lead.company.isNotEmpty) fields['Company'] = lead.company;

      // Add new fields if available (only fields that exist in Airtable)
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record =
          await _airtableService.updateRecord(_tableName, lead.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to update lead even after removing Lead Owner field: $e');
    }
  }

  /// Create lead without Company field
  Future<Lead> _createLeadWithoutCompany(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Always include these basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;
      if (lead.source.isNotEmpty) fields['Source'] = lead.source;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available (but NOT the Company field)
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record = await _airtableService.createRecord(_tableName, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to create lead even after removing Company field: $e');
    }
  }

  /// Update lead without Company field
  Future<Lead> _updateLeadWithoutCompany(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Always include these basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;
      if (lead.source.isNotEmpty) fields['Source'] = lead.source;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available (but NOT the Company field)
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record =
          await _airtableService.updateRecord(_tableName, lead.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to update lead even after removing Company field: $e');
    }
  }

  /// Create lead with linked record handling
  Future<Lead> _createLeadWithLinkedRecordHandling(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Add basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;
      if (lead.source.isNotEmpty) fields['Source'] = lead.source;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      // Handle Company field - only send if it's not a record ID
      if (lead.company.isNotEmpty && !lead.company.startsWith('rec')) {
        fields['Company'] = lead.company;
      }

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record = await _airtableService.createRecord(_tableName, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to create lead even after handling linked records: $e');
    }
  }

  /// Update lead with linked record handling
  Future<Lead> _updateLeadWithLinkedRecordHandling(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Add basic required fields
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;
      if (lead.source.isNotEmpty) fields['Source'] = lead.source;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      // Handle Company field - only send if it's not a record ID
      if (lead.company.isNotEmpty && !lead.company.startsWith('rec')) {
        fields['Company'] = lead.company;
      }

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record =
          await _airtableService.updateRecord(_tableName, lead.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to update lead even after handling linked records: $e');
    }
  }

  /// Helper method to validate Status field options
  bool _isValidStatus(String status) {
    const validStatuses = [
      'New',
      'Contacted',
      'Qualified',
      'Proposal',
      'Won',
      'Lost'
    ];
    return validStatuses.contains(status);
  }

  /// Helper method to validate Source field options
  bool _isValidSource(String source) {
    const validSources = [
      'Website',
      'Referral',
      'Social Media',
      'Event',
      'Other'
    ];
    return validSources.contains(source);
  }

  /// Create lead with valid select options
  Future<Lead> _createLeadWithValidSelectOptions(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Always include these basic required fields with valid options
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      if (lead.company.isNotEmpty) fields['Company'] = lead.company;

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record = await _airtableService.createRecord(_tableName, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to create lead even after using valid select options: $e');
    }
  }

  /// Update lead with valid select options
  Future<Lead> _updateLeadWithValidSelectOptions(Lead lead) async {
    try {
      final fields = <String, dynamic>{};

      // Always include these basic required fields with valid options
      fields['Name'] = lead.name;
      fields['Email'] = lead.email;
      fields['Status'] = 'New'; // Always use valid option
      fields['Source'] = 'Other'; // Always use valid option

      // Conditionally include other fields only if they have values
      if (lead.phone.isNotEmpty) fields['Phone'] = lead.phone;

      // Handle Notes field - it's a linked record field in Airtable, so we don't send text directly
      // We'll skip sending notes as text and instead create separate note records if needed

      if (lead.company.isNotEmpty) fields['Company'] = lead.company;

      // Add userId if available and valid as Lead Owner
      // In Airtable, the field is named "Lead Owner", not "User"
      if (lead.userId != null &&
          lead.userId!.isNotEmpty &&
          lead.userId!.startsWith('rec')) {
        // Send as a linked record (array of record IDs)
        fields['Lead Owner'] = [
          lead.userId
        ]; // Correct field name is "Lead Owner"
      }

      // Add new fields if available
      if (lead.contactName != null && lead.contactName!.isNotEmpty) {
        fields['Contact Name'] = lead.contactName;
      }

      // Add location fields if available
      if (lead.latitude != null && lead.longitude != null) {
        fields['Latitude'] = lead.latitude;
        fields['Longitude'] = lead.longitude;
      }

      if (lead.locationAddress != null && lead.locationAddress!.isNotEmpty) {
        fields['Location Address'] = lead.locationAddress;
      }

      // Do NOT send computed fields

      // Handle Next Follow-up field with proper date format
      if (lead.nextFollowUp != null) {
        // Airtable expects date in YYYY-MM-DD format for date fields
        fields['Next Follow-up'] =
            "${lead.nextFollowUp!.year}-${lead.nextFollowUp!.month.toString().padLeft(2, '0')}-${lead.nextFollowUp!.day.toString().padLeft(2, '0')}";
      }

      final record =
          await _airtableService.updateRecord(_tableName, lead.id, fields);
      final recordFields = record['fields'] as Map<String, dynamic>;

      return Lead(
        id: record['id'] as String,
        name: _getStringValue(recordFields['Name']) ?? '',
        email: _getStringValue(recordFields['Email']) ?? '',
        phone: _getStringValue(recordFields['Phone']) ?? '',
        company: _getStringValue(recordFields['Company']) ?? '',
        source: _getStringValue(recordFields['Source']) ?? '',
        status: _getStringValue(recordFields['Status']) ?? 'New',
        notes: _getStringValue(recordFields['Notes']) ??
            '', // This will be linked records, not text
        createdAt: DateTime.parse(_getStringValue(recordFields['Created At']) ??
            DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(_getStringValue(recordFields['Updated At']) ??
            DateTime.now().toIso8601String()),
        nextFollowUp: recordFields['Next Follow-up'] != null
            ? DateTime.parse(_getStringValue(recordFields['Next Follow-up'])!)
            : null,
        userId: _getStringValue(
            recordFields['Lead Owner']), // Correct field name is "Lead Owner"
        contactName: _getStringValue(
            recordFields['Contact Name']), // Add contactName field
        // Location fields
        latitude: recordFields['Latitude'] as double?,
        longitude: recordFields['Longitude'] as double?,
        locationAddress: _getStringValue(recordFields['Location Address']),
      );
    } catch (e) {
      throw Exception(
          'Failed to update lead even after using valid select options: $e');
    }
  }
}
