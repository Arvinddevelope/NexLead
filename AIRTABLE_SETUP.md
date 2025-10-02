# Airtable Setup Guide for NexLead CRM

## Step 1: Create Airtable Account

1. Go to [airtable.com](https://airtable.com)
2. Sign up for a free account or log in if you already have one

## Step 2: Create a New Base

1. Click on the "+" button to create a new base
2. Select "Start from scratch"
3. Name your base "NexLead CRM"

## Step 3: Create Tables

### Leads Table

1. Rename the default table to "Leads"
2. Add the following fields:
   - Name (Single line text)
   - Email (Email)
   - Phone (Phone number)
   - Company (Single line text)
   - Source (Single line text)
   - Status (Single select) with options:
     - New
     - Contacted
     - Qualified
     - Converted
     - Lost
   - Notes (Long text)
   - Created At (Created time)
   - Updated At (Last modified time)
   - Next Follow-up (Date)

### Notes Table

1. Create a new table named "Notes"
2. Add the following fields:
   - Lead ID (Linked record to Leads)
   - Content (Long text)
   - Created At (Created time)
   - Updated At (Last modified time)

### Tasks Table

1. Create a new table named "Tasks"
2. Add the following fields:
   - Lead ID (Linked record to Leads)
   - Title (Single line text)
   - Description (Long text)
   - Due Date (Date)
   - Completed (Checkbox)
   - Created At (Created time)
   - Updated At (Last modified time)

### Settings Table

1. Create a new table named "Settings"
2. Add the following fields:
   - Dark Mode (Checkbox)
   - Notifications (Checkbox)
   - User Name (Single line text)
   - User Email (Email)

## Step 4: Get API Credentials

1. Go to your Airtable account settings
2. Click on "Developer"
3. Generate a new API key or use an existing one
4. Copy your API key

## Step 5: Get Base ID

1. Go to your base
2. Copy the base ID from the URL
3. The base ID is the string after "https://airtable.com/" in the URL

## Step 6: Configure the App

1. Open `lib/core/config/airtable_config.dart`
2. Replace `YOUR_AIRTABLE_API_KEY` with your actual API key
3. Replace `YOUR_AIRTABLE_BASE_ID` with your actual base ID

## Step 7: Test the Connection

1. Run the app
2. Try creating a new lead to test the connection