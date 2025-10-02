# How to Connect Airtable Database to NexLead CRM

## Overview

This document provides step-by-step instructions to connect your Airtable database to the NexLead CRM application.

## Prerequisites

1. Flutter SDK installed
2. Airtable account (free tier available at [airtable.com](https://airtable.com))
3. This NexLead CRM project

## Step 1: Create Airtable Base

1. Log in to your Airtable account
2. Click the "+" button to create a new base
3. Select "Start from scratch"
4. Name your base "NexLead CRM"

## Step 2: Set up Tables

### Leads Table
1. Rename the default table to "Leads"
2. Add these fields:
   - **Name** (Single line text)
   - **Email** (Email)
   - **Phone** (Phone number)
   - **Company** (Single line text)
   - **Source** (Single line text)
   - **Status** (Single select) with options: New, Contacted, Qualified, Converted, Lost
   - **Notes** (Long text)
   - **Created At** (Created time)
   - **Updated At** (Last modified time)
   - **Next Follow-up** (Date)

### Notes Table
1. Create a new table named "Notes"
2. Add these fields:
   - **Lead ID** (Linked record to Leads)
   - **Content** (Long text)
   - **Created At** (Created time)
   - **Updated At** (Last modified time)

### Tasks Table
1. Create a new table named "Tasks"
2. Add these fields:
   - **Lead ID** (Linked record to Leads)
   - **Title** (Single line text)
   - **Description** (Long text)
   - **Due Date** (Date)
   - **Completed** (Checkbox)
   - **Created At** (Created time)
   - **Updated At** (Last modified time)

### Settings Table
1. Create a new table named "Settings"
2. Add these fields:
   - **Dark Mode** (Checkbox)
   - **Notifications** (Checkbox)
   - **User Name** (Single line text)
   - **User Email** (Email)

## Step 3: Get API Credentials

1. In Airtable, go to Account → Developer
2. Generate a new API key or copy an existing one
3. Copy your Base ID from the URL when viewing your base:
   - The URL looks like: `https://airtable.com/appXXXXXXXXXXXXXX/...`
   - Your Base ID is the `appXXXXXXXXXXXXXX` part

## Step 4: Configure the App

Open `lib/core/config/airtable_config.dart` and update:

```dart
class AirtableConfig {
  // Replace with your actual Airtable API key
  static const String apiKey = 'YOUR_REAL_API_KEY_HERE';
  
  // Replace with your actual Airtable base ID
  static const String baseId = 'YOUR_REAL_BASE_ID_HERE';
  
  // These table names should match your Airtable table names
  static const String leadsTable = 'Leads';
  static const String notesTable = 'Notes';
  static const String tasksTable = 'Tasks';
  static const String settingsTable = 'Settings';
}
```

## Step 5: Test the Connection

1. Save the configuration file
2. Run the app: `flutter run`
3. The app will show configuration status on startup
4. Try creating a new lead to test the connection

## Troubleshooting

### Common Issues

1. **API Key Not Working**
   - Ensure you copied the full API key
   - Check that your Airtable account is active
   - Verify you have access to the base

2. **Base ID Incorrect**
   - Double-check the Base ID from the URL
   - Make sure there are no extra spaces

3. **Network Errors**
   - Ensure you have internet connectivity
   - Check firewall settings if behind corporate network

### Error Messages

- **"401 Unauthorized"**: API key is incorrect or missing
- **"404 Not Found"**: Base ID or table name is incorrect
- **"422 Unprocessable Entity"**: Data format doesn't match Airtable field types

## Security Best Practices

1. **Never commit real API keys** to version control
2. For production apps, consider:
   - Using environment variables
   - Implementing a backend proxy
   - Adding rate limiting
   - Using OAuth for user authentication

## Next Steps

1. Test all CRUD operations:
   - Create new leads, notes, and tasks
   - View and edit existing records
   - Delete records

2. Explore advanced features:
   - Add filtering and sorting
   - Implement data validation
   - Add offline support with local caching

3. Monitor usage:
   - Airtable has API rate limits
   - Track API usage in your Airtable account

## Support

For issues with this integration:
1. Check the Airtable API documentation
2. Review the console logs in the Flutter app
3. Verify your table structure matches the expected fields