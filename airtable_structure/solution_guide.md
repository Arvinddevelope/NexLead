# Airtable Leads Table Setup Guide

## Problem
You're getting the error: `UNKNOWN_FIELD_NAME: Unknown field name: {Company}` when trying to create leads. This means your Airtable Leads table doesn't have a field named "Company".

## Solution Options

### Option 1: Add the Missing Fields to Your Airtable Table (Recommended)

1. Open your Airtable base
2. Go to the "Leads" table
3. Add the following fields if they don't exist:
   - **Name** (Single line text)
   - **Email** (Email)
   - **Phone** (Phone number)
   - **Company** (Single line text)
   - **Source** (Single select)
   - **Status** (Single select)
   - **Notes** (Long text)
   - **Created At** (Created time)
   - **Updated At** (Last modified time)
   - **Next Follow-up** (Date)

### Option 2: Update Your Airtable Table Structure

If you already have fields with different names:
1. Rename your existing fields to match the names above, OR
2. Update the field mapping in the code to match your actual field names

## Recommended Table Structure

See the file `leads_table_structure.csv` for the complete recommended structure.

## Error Handling

The updated code now handles missing fields gracefully:
- It tries to create records with all fields first
- If it fails due to a missing "Company" field, it automatically retries without that field
- This prevents the application from crashing and allows leads to be created

## Testing

After updating your table:
1. Restart your Flutter application
2. Try creating a new lead again
3. Check that the lead appears in your Airtable table