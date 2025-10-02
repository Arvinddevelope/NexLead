# User-Specific Data Feature

## Overview
This feature ensures that each user only sees their own leads in the application. When a user logs in, they will only see leads that are associated with their user ID.

## Implementation Details

### 1. Data Model Changes
- Added a `userId` field to the [Lead](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/data/models/lead_model.dart#L1-L49) model to associate leads with users
- Updated the [Lead](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/data/models/lead_model.dart#L1-L49) model's `toJson` and `fromJson` methods to handle the new field
- Updated the `copyWith` method to include the `userId` field

### 2. Service Layer Changes
- Added a `getLeadsByUserId` method to [LeadService](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/data/services/lead_service.dart#L5-L552) to fetch only leads associated with a specific user
- Modified all create and update methods to include the user ID when saving leads
- Updated all methods to handle the new `userId` field when reading leads

### 3. Repository Layer Changes
- Added a `getLeadsByUserId` method to [LeadRepository](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/data/repositories/lead_repository.dart#L3-L33) that calls the corresponding service method

### 4. Provider Layer Changes
- Added a `setCurrentUserId` method to [LeadProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/lead_provider.dart#L5-L152) to set the current user ID
- Modified the `loadLeads` method to fetch user-specific leads when a user ID is set
- Updated `createLead` and `updateLead` methods to associate leads with the current user

### 5. Application Setup Changes
- Modified [main.dart](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/main.dart) to use `ChangeNotifierProxyProvider` to connect the [AuthProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/auth_provider.dart#L5-L130) with the [LeadProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/lead_provider.dart#L5-L152)
- This ensures that when a user logs in, their ID is automatically set in the [LeadProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/lead_provider.dart#L5-L152)

## How It Works

1. When a user logs in, the [AuthProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/auth_provider.dart#L5-L130) stores the current user information
2. The `ChangeNotifierProxyProvider` in [main.dart](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/main.dart) automatically updates the [LeadProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/lead_provider.dart#L5-L152) with the current user's ID
3. When the [LeadProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/lead_provider.dart#L5-L152) loads leads, it uses the `getLeadsByUserId` method to fetch only leads associated with the current user
4. When creating or updating leads, the [LeadProvider](file:///c:/Users/Arvind/Desktop/NextLead/nextlead/lib/providers/lead_provider.dart#L5-L152) automatically associates the lead with the current user

## Airtable Setup Requirements

To make this feature work properly, you need to ensure your Airtable Leads table has:
1. A "User" field (linked record field) that links to the Users table
2. Proper field mapping in your application to match your Airtable field names

## Testing the Feature

1. Log in with different user accounts
2. Create leads with each account
3. Verify that each user only sees their own leads
4. Check that leads created by one user are not visible to other users

## Future Enhancements

1. Add user-specific filtering to other data types (Notes, Tasks)
2. Implement role-based access control for team collaboration
3. Add sharing capabilities for leads between users