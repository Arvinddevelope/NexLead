# Airtable Users Table Setup Guide

## Overview

This guide explains how to set up the Users table in your Airtable base for the NexLead CRM application authentication system.

## Step 1: Create the Users Table

1. In your Airtable base, click the "+" button to add a new table
2. Select "Rename this table" and name it "Users"
3. Click "Create"

## Step 2: Add Required Fields

Add the following fields to your Users table:

### 1. Name (Single line text)
- Field Name: `Name`
- Field Type: Single line text
- Required: Yes

### 2. Email (Email)
- Field Name: `Email`
- Field Type: Email
- Required: Yes
- Recommendation: Set as unique identifier

### 3. Password (Single line text)
- Field Name: `Password`
- Field Type: Single line text
- Required: Yes
- Note: In a production environment, this should store hashed passwords

### 4. Created At (Created time)
- Field Name: `Created At`
- Field Type: Created time
- Required: Yes
- Configuration: 
  - Use the default "Created time" option
  - This will automatically populate when records are created

### 5. Updated At (Last modified time)
- Field Name: `Updated At`
- Field Type: Last modified time
- Required: Yes
- Configuration:
  - Use the default "Last modified time" option
  - This will automatically update when records are modified

## Step 3: Configure Field Options

### Email Field Configuration
1. Click on the Email field
2. In the field settings, enable "Unique values" to prevent duplicate accounts
3. This ensures each user has a unique email address

### Password Field Configuration
1. Click on the Password field
2. In the field settings, enable "Mask characters" for security
3. This will hide the password characters when viewing records

## Step 4: Test the Setup

1. Add a test user record manually:
   - Name: Test User
   - Email: test@example.com
   - Password: test123
2. Verify that:
   - Created At field auto-populates
   - Updated At field auto-populates
   - Email uniqueness is enforced

## Important Security Notes

### For Development/Testing
- Storing plain text passwords is acceptable for development
- Never use real user passwords in development

### For Production
- Implement proper password hashing before storing
- Consider using a more secure authentication system
- Add additional security fields like:
  - Password salt
  - Last login timestamp
  - Account status (active/inactive)
  - Password reset token
  - Two-factor authentication fields

## Integration with NexLead CRM

The Users table integrates with the application through:
1. `UserService` - Handles API calls to Airtable
2. `UserRepository` - Abstracts data access
3. `AuthProvider` - Manages authentication state

## Troubleshooting

### Common Issues

1. **Authentication Fails**
   - Check that email and password match exactly
   - Verify field names match the User model
   - Ensure Airtable API key and base ID are correctly configured

2. **User Creation Fails**
   - Check that required fields are populated
   - Verify email uniqueness constraint
   - Confirm Airtable API permissions

3. **Connection Errors**
   - Verify internet connectivity
   - Check Airtable API key validity
   - Confirm base ID is correct

### Error Messages

- **"Invalid email or password"**: Credentials don't match stored values
- **"User with this email already exists"**: Attempting to create duplicate account
- **"Failed to create user"**: API error, check Airtable logs
- **"Failed to fetch user"**: Network or API error

## Next Steps

1. Test login and signup functionality in the app
2. Add sample users for testing
3. Implement additional user management features
4. Consider adding user roles/permissions for future enhancements