import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';

void main() async {
  print('Testing Lead Creation with Select Options Error Handling...');

  try {
    // Create services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);

    // Test 1: Create a lead with invalid select options (should be handled by _createLeadWithValidSelectOptions)
    final testLead = Lead(
      id: 'test-invalid-options',
      name: 'Test Lead Invalid Select Options',
      email: 'invalid-options@example.com',
      phone: '1234567890',
      company: 'Test Company',
      source: 'Invalid Source Option', // Invalid source option
      status: 'Invalid Status Option', // Invalid status option
      notes: 'Test notes with invalid select options',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: DateTime.now().add(const Duration(days: 7)),
      userId: null,
      contactName: 'John Doe',
    );

    print('Test: Creating lead with invalid select options...');
    final createdLead = await leadService.createLead(testLead);
    print('✅ Lead created successfully!');
    print('Lead ID: ${createdLead.id}');
    print('Lead Name: ${createdLead.name}');
    print('Lead Status: ${createdLead.status}'); // Should be defaulted to 'New'
    print(
        'Lead Source: ${createdLead.source}'); // Should be defaulted to 'Other'

    // Verify that the lead was created with valid options
    if (createdLead.status == 'New' && createdLead.source == 'Other') {
      print('✅ Select options were correctly defaulted to valid values!');
    } else {
      print('❌ Select options were not correctly defaulted!');
      print('Expected: Status="New", Source="Other"');
      print(
          'Actual: Status="${createdLead.status}", Source="${createdLead.source}"');
    }

    print('\n🎉 Test completed successfully!');
  } catch (e) {
    print('❌ Error during test: $e');
  }
}
