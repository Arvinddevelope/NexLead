# Airtable Database Structure

This directory contains CSV files that define the structure of the Airtable database for the NexLead CRM application.

## Files

1. **[leads_table.csv](file://c:\Users\Arvind\Desktop\NexLead\nextlead\airtable_structure\leads_table.csv)** - Structure for the Leads table
2. **[notes_table.csv](file://c:\Users\Arvind\Desktop\NexLead\nextlead\airtable_structure\notes_table.csv)** - Structure for the Notes table
3. **[tasks_table.csv](file://c:\Users\Arvind\Desktop\NexLead\nextlead\airtable_structure\tasks_table.csv)** - Structure for the Tasks table
4. **[settings_table.csv](file://c:\Users\Arvind\Desktop\NexLead\nextlead\airtable_structure\settings_table.csv)** - Structure for the Settings table
5. **[users_table.csv](file://c:\Users\Arvind\Desktop\NexLead\nextlead\airtable_structure\users_table.csv)** - Structure for the Users table
6. **[database_overview.csv](file://c:\Users\Arvind\Desktop\NexLead\nextlead\airtable_structure\database_overview.csv)** - Overview of all tables and their relationships

## How to Use

When creating your Airtable base for NexLead CRM:

1. Create a new base in Airtable
2. Create each table using the field definitions in the corresponding CSV file
3. Set up the linked record relationships between tables as specified:
   - Notes.Lead ID → Links to Leads
   - Tasks.Lead ID → Links to Leads
4. Ensure field types match exactly what's specified in the CSV files

## Column Definitions

In each table CSV file:
- **Field Name**: The name of the field in Airtable
- **Field Type**: The Airtable field type
- **Description**: Explanation of the field's purpose
- **Required**: Whether the field is required (Yes/No)
- **Linked Table**: For linked record fields, which table it links to

## Important Notes

- All timestamp fields (Created At, Updated At) are automatically managed by Airtable
- The Status field in Leads table must have the exact options: New, Contacted, Qualified, Converted, Lost
- Linked record fields establish the relationships between tables