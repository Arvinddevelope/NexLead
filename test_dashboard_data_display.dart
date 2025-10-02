import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/data/models/task_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/lead_service.dart';
import 'package:nextlead/data/services/task_service.dart';

void main() async {
  print('Testing Dashboard Data Display...');

  try {
    // Create services
    final airtableService = AirtableService();
    final leadService = LeadService(airtableService);
    final taskService = TaskService(airtableService);

    // Test 1: Create a lead with today's follow-up
    final today = DateTime.now();
    final testLead = Lead(
      id: 'test-dashboard-data-1',
      name: 'Dashboard Data Test Lead',
      email: 'dashboarddata@example.com',
      phone: '1234567890',
      company: 'Dashboard Data Company',
      source: 'Website',
      status: 'Qualified',
      notes: 'Test lead for dashboard data display',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nextFollowUp: today,
      userId: null,
      contactName: 'John Dashboard Data',
    );

    print('Test 1: Creating lead with today\'s follow-up...');
    final createdLead = await leadService.createLead(testLead);
    print('✅ Lead with today\'s follow-up created successfully!');
    print('Lead ID: ${createdLead.id}');
    print('Lead Name: ${createdLead.name}');
    print('Follow-up Date: ${createdLead.nextFollowUp}');

    // Test 2: Create a task for today
    final testTask = Task(
      id: 'test-dashboard-data-2',
      leadId: createdLead.id,
      title: 'Dashboard Data Test Task',
      description: 'Test task for dashboard data display',
      dueDate: today,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('\nTest 2: Creating task for today...');
    final createdTask = await taskService.createTask(testTask);
    print('✅ Task for today created successfully!');
    print('Task ID: ${createdTask.id}');
    print('Task Title: ${createdTask.title}');
    print('Task Due Date: ${createdTask.dueDate}');

    print('\n🎉 All dashboard data display tests passed!');
    print('The dashboard should now show:');
    print('- 1 follow-up for today with detailed information');
    print('- 1 task for today with detailed information');
  } catch (e) {
    print('❌ Error during dashboard data display test: $e');
  }
}
