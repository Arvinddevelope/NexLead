# NexLead CRM

A professional Lead Management CRM app built with Flutter and Airtable.

## Getting Started

### Prerequisites

- Flutter SDK
- Airtable account

### Setup

1. Clone the repository
2. Run `flutter pub get`
3. Create an Airtable base with the following tables:
   - Leads
   - Notes
   - Tasks
   - Settings
4. Update the Airtable configuration in `lib/core/config/airtable_config.dart` with your API key and base ID
5. Run the app with `flutter run`

### Airtable Base Setup

Create tables with the following fields:

**Leads Table:**
- Name (Single line text)
- Email (Email)
- Phone (Phone number)
- Company (Single line text)
- Source (Single line text)
- Status (Single select: New, Contacted, Qualified, Converted, Lost)
- Notes (Long text)
- Created At (Created time)
- Updated At (Last modified time)
- Next Follow-up (Date)

**Notes Table:**
- Lead ID (Linked record to Leads)
- Content (Long text)
- Created At (Created time)
- Updated At (Last modified time)

**Tasks Table:**
- Lead ID (Linked record to Leads)
- Title (Single line text)
- Description (Long text)
- Due Date (Date)
- Completed (Checkbox)
- Created At (Created time)
- Updated At (Last modified time)

**Settings Table:**
- Dark Mode (Checkbox)
- Notifications (Checkbox)
- User Name (Single line text)
- User Email (Email)

### Running the App

- For web: `flutter run -d chrome`
- For mobile: `flutter run`

### Building for Production

- Web: `flutter build web`
- Android: `flutter build apk`
- iOS: `flutter build ios`
