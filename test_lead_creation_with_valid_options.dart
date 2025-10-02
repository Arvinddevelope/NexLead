import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';

void main() async {
  print('Testing Lead Creation with Valid Select Options...');

  try {
    // Create services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);

    // Test 1: Create a lead with valid select options
    final testLead1 = Lead(
      id: 'test1',
      name: 'Test Lead Valid Options',
      email: 'valid@example.com',
      phone: '1234567890',
      company: 'Test Company',
      source: 'Website', // Valid source option
      status: 'New', // Valid status option
      notes: 'Test notes',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: DateTime.now().add(const Duration(days: 7)),
      userId: null,
      contactName: 'John Doe',
      // Note: Removed lastStatus and lastSource as they don't exist in Airtable
    );

    print('Test 1: Creating lead with valid select options...');
    final createdLead1 = await leadService.createLead(testLead1);
    print('✅ Lead created successfully with valid options!');
    print('Lead ID: ${createdLead1.id}');
    print('Lead Status: ${createdLead1.status}');
    print('Lead Source: ${createdLead1.source}');

    // Test 2: Create a lead with invalid select options (should default to valid ones)
    final testLead2 = Lead(
      id: 'test2',
      name: 'Test Lead Invalid Options',
      email: 'invalid@example.com',
      phone: '0987654321',
      company: 'Another Company',
      source: 'Invalid Source', // Invalid source option
      status: 'Invalid Status', // Invalid status option
      notes: 'Test notes with invalid options',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: DateTime.now().add(const Duration(days: 14)),
      userId: null,
      contactName: 'Jane Smith',
      // Note: Removed lastStatus and lastSource as they don't exist in Airtable
    );

    print('\nTest 2: Creating lead with invalid select options...');
    final createdLead2 = await leadService.createLead(testLead2);
    print('✅ Lead created successfully with defaulted valid options!');
    print('Lead ID: ${createdLead2.id}');
    print('Lead Status: ${createdLead2.status}'); // Should be 'New'
    print('Lead Source: ${createdLead2.source}'); // Should be 'Other'

    print('\n🎉 All tests passed!');
  } catch (e) {
    print('❌ Error creating lead: $e');
  }
}
