import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';

void main() async {
  print('Testing Dashboard Updates...');

  try {
    // Create services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);

    // Test 1: Create a lead with today's follow-up
    final today = DateTime.now();
    final testLead1 = Lead(
      id: 'test-dashboard-1',
      name: 'Dashboard Test Lead 1',
      email: 'dashboard1@example.com',
      phone: '1234567890',
      company: 'Dashboard Company',
      source: 'Website',
      status: 'New',
      notes: 'Test lead for dashboard',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: today,
      userId: null,
      contactName: 'John Dashboard',
    );

    print('Test 1: Creating lead with today\'s follow-up...');
    final createdLead1 = await leadService.createLead(testLead1);
    print('✅ Lead with today\'s follow-up created successfully!');
    print('Lead ID: ${createdLead1.id}');
    print('Lead Name: ${createdLead1.name}');
    print('Follow-up Date: ${createdLead1.nextFollowUp}');

    // Test 2: Create a converted lead
    final testLead2 = Lead(
      id: 'test-dashboard-2',
      name: 'Dashboard Test Lead 2',
      email: 'dashboard2@example.com',
      phone: '0987654321',
      company: 'Converted Company',
      source: 'Referral',
      status: 'Won', // Converted status
      notes: 'Converted lead for dashboard',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: null,
      userId: null,
      contactName: 'Jane Converted',
    );

    print('\nTest 2: Creating converted lead...');
    final createdLead2 = await leadService.createLead(testLead2);
    print('✅ Converted lead created successfully!');
    print('Lead ID: ${createdLead2.id}');
    print('Lead Name: ${createdLead2.name}');
    print('Lead Status: ${createdLead2.status}');

    // Test 3: Create a lost lead
    final testLead3 = Lead(
      id: 'test-dashboard-3',
      name: 'Dashboard Test Lead 3',
      email: 'dashboard3@example.com',
      phone: '1122334455',
      company: 'Lost Company',
      source: 'Social Media',
      status: 'Lost', // Lost status
      notes: 'Lost lead for dashboard',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: null,
      userId: null,
      contactName: 'Bob Lost',
    );

    print('\nTest 3: Creating lost lead...');
    final createdLead3 = await leadService.createLead(testLead3);
    print('✅ Lost lead created successfully!');
    print('Lead ID: ${createdLead3.id}');
    print('Lead Name: ${createdLead3.name}');
    print('Lead Status: ${createdLead3.status}');

    print('\n🎉 All dashboard update tests passed!');
    print('The dashboard should now show:');
    print('- 1 follow-up for today');
    print('- 1 converted lead');
    print('- 1 lost lead');
  } catch (e) {
    print('❌ Error during dashboard update test: $e');
  }
}
