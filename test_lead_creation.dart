import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';

void main() async {
  print('Testing Lead Creation...');

  try {
    // Create services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);

    // Create a comprehensive test lead with all supported fields
    final testLead = Lead(
      id: 'test',
      name: 'Comprehensive Test Lead',
      email: 'comprehensive@example.com',
      phone: '9876543210',
      company: 'Test Company Inc.',
      source: 'Website',
      status: 'New',
      notes: 'Comprehensive test notes',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: DateTime.now().add(const Duration(days: 14)),
      userId: null, // We'll test user association separately
      contactName: 'Jane Smith',
      // Note: Removed lastStatus and lastSource as they don't exist in Airtable
    );

    print('Creating comprehensive lead...');
    final createdLead = await leadService.createLead(testLead);
    print('✅ Comprehensive lead created successfully!');
    print('Lead ID: ${createdLead.id}');
    print('Lead Name: ${createdLead.name}');
    print('Lead Email: ${createdLead.email}');
    print('Lead Phone: ${createdLead.phone}');
    print('Lead Company: ${createdLead.company}');
    print('Lead Source: ${createdLead.source}');
    print('Lead Status: ${createdLead.status}');
    print('Lead Contact Name: ${createdLead.contactName}');
    print('Lead Next Follow-up: ${createdLead.nextFollowUp}');

    // Test updating the lead
    final updatedLead = createdLead.copyWith(
      status: 'Contacted',
      notes: 'Updated notes after contact',
    );

    print('Updating lead...');
    final updatedLeadResult = await leadService.updateLead(updatedLead);
    print('✅ Lead updated successfully!');
    print('Updated Status: ${updatedLeadResult.status}');
    print('Updated Notes: ${updatedLeadResult.notes}');

    // Test retrieving the lead
    print('Retrieving lead...');
    final retrievedLead = await leadService.getLeadById(createdLead.id);
    print('✅ Lead retrieved successfully!');
    print('Retrieved Name: ${retrievedLead.name}');
    print('Retrieved Status: ${retrievedLead.status}');

    print('🎉 All comprehensive tests passed!');
  } catch (e) {
    print('❌ Error in comprehensive test: $e');
  }
}
