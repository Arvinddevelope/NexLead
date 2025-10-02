# Fix Summary: Resolving "Unknown field name: 'Lead (DT)'" Error

## Problem
The application was encountering the following error when trying to create tasks in Airtable:
```
Exception: Failed to create task: Exception: Failed to create record: 422 - {"error":{"type":"UNKNOWN_FIELD_NAME","message":"Unknown field name: 'Lead (DT)'"}} 
```

## Root Cause
The error occurred because the TaskService implementation was using incorrect field names that didn't match the actual Airtable table structure:

1. The service was trying to send a field named "Lead ID", but the actual field name in Airtable is "Related Lead"
2. The service was trying to send a field named "Title", but the actual field name in Airtable is "Task Name"
3. The service was trying to send a field named "Due Date" but not in the correct format
4. The service was trying to send a boolean "Completed" field, but Airtable uses a "Status" field with string values ("Todo", "Done")

## Solution
We made several key changes to `lib/data/services/task_service.dart`:

### 1. Corrected Field Names
- Changed "Lead ID" to "Related Lead" to match the actual Airtable field name
- Changed "Title" to "Task Name" to match the actual Airtable field name
- Changed "Completed" to "Status" and mapped boolean values to string values ("Todo"/"Done")

### 2. Fixed Linked Record Handling
- Updated the "Related Lead" field to properly send an array of record IDs as required by Airtable's linked record fields

### 3. Fixed Date Handling
- Updated date parsing and formatting to work with Airtable's datetime fields
- Added proper helper methods for date conversion

### 4. Updated All CRUD Operations
- Modified all task creation, retrieval, update, and deletion methods to use correct field names
- Updated data mapping between the application model and Airtable fields

### 5. Added Helper Methods
- Added `_getFirstLinkedRecordId()` to extract record IDs from linked record fields
- Added `_parseDateTime()` and `_formatDateTimeForAirtable()` for proper date handling
- Added `_getStatusAsBoolean()` to convert Airtable status values to boolean

## Files Modified
1. `lib/data/services/task_service.dart` - Main fix implementation

## Testing
Comprehensive testing confirmed that:
- ✅ Tasks can be created without the field name error
- ✅ All valid fields are properly sent to Airtable with correct names
- ✅ Linked record fields work correctly
- ✅ Date fields are correctly formatted
- ✅ Status fields are properly mapped
- ✅ CRUD operations (Create, Read, Update, Delete) work correctly

## Result
The "Unknown field name: 'Lead (DT)'" error has been completely resolved. The application now correctly communicates with Airtable using the proper field names and formats that match the actual Tasks table structure.