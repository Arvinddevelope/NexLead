# Added New Fields to Lead Model

## Overview
This update adds three new fields to the Lead model to store additional information as requested:
1. Contact Name
2. Last Status
3. Last SOURCE

## Fields Added

### 1. Contact Name
- **Purpose**: Stores the name of the primary contact person at the company
- **Type**: String (optional)
- **Usage**: Useful when the lead is associated with a company but you want to track the specific person to contact

### 2. Last Status
- **Purpose**: Stores the previous status of the lead before the current status
- **Type**: String (optional)
- **Usage**: Useful for tracking status changes and maintaining a history of lead progression

### 3. Last SOURCE
- **Purpose**: Stores the previous source of the lead before any source changes
- **Type**: String (optional)
- **Usage**: Useful for tracking how the lead source might change over time

## Implementation Details

### Data Model Changes
- Added `contactName`, `lastStatus`, and `lastSource` fields to the [Lead](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/data/models/lead_model.dart#L1-L102) model
- Updated the `Lead.fromJson` factory constructor to handle the new fields
- Updated the `toJson` method to include the new fields
- Updated the `copyWith` method to include the new fields

### Service Layer Changes
- Updated [LeadService](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/data/services/lead_service.dart#L5-L597) to read and write the new fields to/from Airtable
- Modified all methods (`getAllLeads`, `getLeadById`, `getLeadsByUserId`, `createLead`, `updateLead`, etc.) to handle the new fields
- Added the new fields to all fallback methods to ensure consistent behavior

### Airtable Integration
- The new fields will be automatically synced with Airtable when leads are created or updated
- Field names in Airtable should match: "Contact Name", "Last Status", and "Last SOURCE"
- These fields are optional and won't cause errors if they don't exist in Airtable

## Usage Examples

### Creating a Lead with New Fields
```dart
final lead = Lead(
  id: '',
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  company: 'Example Corp',
  source: 'Website',
  status: 'New',
  notes: 'Interested in our services',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  contactName: 'John Doe',
  lastStatus: 'Contacted',
  lastSource: 'Referral',
);
```

### Updating a Lead with New Fields
```dart
final updatedLead = lead.copyWith(
  status: 'Qualified',
  lastStatus: lead.status, // Store previous status
  contactName: 'Jane Smith',
);
```

## Airtable Setup

To use these new fields with Airtable, ensure your Leads table has the following fields:
1. **Contact Name** (Single line text)
2. **Last Status** (Single line text)
3. **Last SOURCE** (Single line text)

If these fields don't exist in your Airtable table, the application will still work but won't store data for these fields.

## Testing

The implementation has been designed to:
1. Work with existing Airtable tables that don't have the new fields
2. Automatically use the new fields when they exist in Airtable
3. Not break existing functionality

You can test by:
1. Creating leads with values for the new fields
2. Verifying the values are stored and retrieved correctly
3. Checking that existing functionality still works as expected