import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';

void main() async {
  print('Testing Lead Metrics Display...');

  try {
    // Create services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);

    // Create test leads with different statuses
    final testLeads = [
      Lead(
        id: 'test-lead-1',
        name: 'Converted Lead Test',
        email: 'converted@example.com',
        phone: '1111111111',
        company: 'Converted Company',
        source: 'Website',
        status: 'Converted',
        notes: 'Test converted lead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nextFollowUp: null,
        userId: null,
        contactName: 'John Converted',
      ),
      Lead(
        id: 'test-lead-2',
        name: 'Proposal Lead Test',
        email: 'proposal@example.com',
        phone: '2222222222',
        company: 'Proposal Company',
        source: 'Referral',
        status: 'Proposal',
        notes: 'Test proposal lead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nextFollowUp: null,
        userId: null,
        contactName: 'Jane Proposal',
      ),
      Lead(
        id: 'test-lead-3',
        name: 'Contacted Lead Test',
        email: 'contacted@example.com',
        phone: '3333333333',
        company: 'Contacted Company',
        source: 'Social Media',
        status: 'Contacted',
        notes: 'Test contacted lead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nextFollowUp: null,
        userId: null,
        contactName: 'Bob Contacted',
      ),
      Lead(
        id: 'test-lead-4',
        name: 'Qualified Lead Test',
        email: 'qualified@example.com',
        phone: '4444444444',
        company: 'Qualified Company',
        source: 'Event',
        status: 'Qualified',
        notes: 'Test qualified lead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nextFollowUp: null,
        userId: null,
        contactName: 'Alice Qualified',
      ),
      Lead(
        id: 'test-lead-5',
        name: 'New Lead Test',
        email: 'new@example.com',
        phone: '5555555555',
        company: 'New Company',
        source: 'Other',
        status: 'New',
        notes: 'Test new lead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nextFollowUp: null,
        userId: null,
        contactName: 'Charlie New',
      ),
      Lead(
        id: 'test-lead-6',
        name: 'Lost Lead Test',
        email: 'lost@example.com',
        phone: '6666666666',
        company: 'Lost Company',
        source: 'Website',
        status: 'Lost',
        notes: 'Test lost lead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nextFollowUp: null,
        userId: null,
        contactName: 'David Lost',
      ),
      Lead(
        id: 'test-lead-7',
        name: 'Won Lead Test',
        email: 'won@example.com',
        phone: '7777777777',
        company: 'Won Company',
        source: 'Referral',
        status: 'Won',
        notes: 'Test won lead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nextFollowUp: null,
        userId: null,
        contactName: 'Eve Won',
      ),
    ];

    print('Creating test leads with different statuses...');

    for (var i = 0; i < testLeads.length; i++) {
      final testLead = testLeads[i];
      try {
        final createdLead = await leadService.createLead(testLead);
        print('✅ Created ${testLead.status} lead: ${createdLead.name}');
      } catch (e) {
        print('❌ Failed to create ${testLead.status} lead: $e');
      }
    }

    print('\n🎉 Test leads created successfully!');
    print('The dashboard should now show all lead status metrics:');
    print('- Total Leads: ${testLeads.length}');
    print('- Converted/Won Leads: Count of Converted + Won leads');
    print('- Proposal Leads: Count of Proposal leads');
    print('- Contacted Leads: Count of Contacted leads');
    print('- Qualified Leads: Count of Qualified leads');
    print('- New Leads: Count of New leads');
    print('- Pending Leads: Count of New + Contacted leads');
    print('- Lost Leads: Count of Lost leads');
  } catch (e) {
    print('❌ Error during lead metrics test: $e');
  }
}
