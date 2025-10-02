# How to Fix the Airtable Users Table Issue

## Problem Analysis

The error you're seeing:
```
Exception: Failed to create user: Exception: Failed to create record: 422
{"error":{"type":"UNKNOWN_FIELD_NAME","message":"Unknown field name: \"Name\""}}
```

This means that your Airtable Users table doesn't have the required fields that the application expects.

## Current State of Your Users Table

Based on the test results, your Users table currently has these fields:
- Role (Single line text)
- Active (Checkbox)
- Leads (Linked record to Leads table)
- Notes (Linked record to Notes table)
- Tasks (Linked record to Tasks table)
- Created At (Created time)
- Updated At (Last modified time)

But it's missing these required fields:
- Name
- Email
- Password

## Solution

You need to add the missing fields to your Airtable Users table:

### Step 1: Add Missing Fields

1. Go to your Airtable base
2. Open the Users table
3. Click on the "+ Add field" button
4. Add the following fields:

#### Field 1: Name
- Click "+ Add field"
- Name the field "Name"
- Set field type to "Single line text"
- Click "Create field"

#### Field 2: Email
- Click "+ Add field"
- Name the field "Email"
- Set field type to "Email"
- Click "Create field"
- Optional: Enable "Unique values" to prevent duplicate accounts

#### Field 3: Password
- Click "+ Add field"
- Name the field "Password"
- Set field type to "Single line text"
- Optional: Enable "Mask characters" for security
- Click "Create field"

### Step 2: Verify Field Names

Make sure the field names match exactly:
- "Name" (with capital N)
- "Email" (with capital E)
- "Password" (with capital P)

Airtable field names are case-sensitive.

### Step 3: Test the Connection

After adding the fields, try creating a user again. The error should be resolved.

## Alternative Solution: Update the Application Code

If you prefer to keep your current table structure, you can update the application code to match your existing field names:

1. Update the User model in `lib/data/models/user_model.dart`
2. Update the UserService in `lib/data/services/user_service.dart`
3. Update the field mappings to match your actual field names

For example, if you want to use "Full Name" instead of "Name", you would update the code to use "Full Name" as the field name.

## Verification

After making these changes, run the app again. The 422 error should be resolved, and you should be able to create users successfully.