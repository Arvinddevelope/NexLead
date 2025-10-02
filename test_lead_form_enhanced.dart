import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';

void main() async {
  print('Testing Enhanced Lead Form Features...');

  try {
    // Create services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);

    // Test 1: Create a lead with all enhanced fields
    final testLead1 = Lead(
      id: 'test-enhanced-1',
      name: 'Enhanced Test Lead 1',
      email: 'enhanced1@example.com',
      phone: '1111111111',
      company: 'Enhanced Company Inc.',
      source: 'Website', // Using predefined source option
      status: 'Qualified', // Using predefined status option
      notes: 'Test notes for enhanced lead form',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: DateTime.now().add(const Duration(days: 5)),
      userId: null,
      contactName: 'John Contact', // New contactName field
    );

    print('Test 1: Creating lead with enhanced fields...');
    final createdLead1 = await leadService.createLead(testLead1);
    print('✅ Enhanced lead created successfully!');
    print('Lead ID: ${createdLead1.id}');
    print('Lead Name: ${createdLead1.name}');
    print('Contact Name: ${createdLead1.contactName}');
    print('Lead Status: ${createdLead1.status}');
    print('Lead Source: ${createdLead1.source}');

    // Test 2: Create a lead with custom source
    final testLead2 = Lead(
      id: 'test-enhanced-2',
      name: 'Enhanced Test Lead 2',
      email: 'enhanced2@example.com',
      phone: '2222222222',
      company: 'Custom Source Company',
      source: 'Custom Marketing Campaign', // Custom source
      status: 'Proposal', // Using predefined status option
      notes: 'Test notes with custom source',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: DateTime.now().add(const Duration(days: 10)),
      userId: null,
      contactName: 'Jane Contact', // New contactName field
    );

    print('\nTest 2: Creating lead with custom source...');
    final createdLead2 = await leadService.createLead(testLead2);
    print('✅ Lead with custom source created successfully!');
    print('Lead ID: ${createdLead2.id}');
    print('Lead Name: ${createdLead2.name}');
    print('Contact Name: ${createdLead2.contactName}');
    print('Lead Status: ${createdLead2.status}');
    print('Lead Source: ${createdLead2.source}');

    // Test 3: Update a lead with enhanced fields
    final updatedLead = createdLead1.copyWith(
      status: 'Proposal',
      source: 'Referral',
      contactName: 'Updated Contact Name',
      notes: 'Updated notes after enhancement',
    );

    print('\nTest 3: Updating lead with enhanced fields...');
    final updatedLeadResult = await leadService.updateLead(updatedLead);
    print('✅ Lead updated successfully!');
    print('Updated Status: ${updatedLeadResult.status}');
    print('Updated Source: ${updatedLeadResult.source}');
    print('Updated Contact Name: ${updatedLeadResult.contactName}');
    print('Updated Notes: ${updatedLeadResult.notes}');

    print('\n🎉 All enhanced lead form tests passed!');
  } catch (e) {
    print('❌ Error during enhanced lead form test: $e');
  }
}
