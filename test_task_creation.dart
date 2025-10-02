import 'package:nextlead/data/models/task_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/task_service.dart';

void main() async {
  print('Testing Task Creation...');

  try {
    // Create services
    final airtableService = AirtableService();
    final taskService = TaskService(airtableService);

    // Create a test task
    final testTask = Task(
      id: 'test',
      leadId:
          'recGoT0ty2myavitM', // Using an existing lead ID from your Airtable
      title: 'Test Task',
      description: 'This is a test task',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('Creating task...');
    final createdTask = await taskService.createTask(testTask);
    print('✅ Task created successfully!');
    print('Task ID: ${createdTask.id}');
    print('Task Title: ${createdTask.title}');
    print('Task Due Date: ${createdTask.dueDate}');
    print('Task Completed: ${createdTask.isCompleted}');

    // Test updating the task
    final updatedTask = createdTask.copyWith(
      isCompleted: true,
      description: 'This is an updated test task',
    );

    print('Updating task...');
    final updatedTaskResult = await taskService.updateTask(updatedTask);
    print('✅ Task updated successfully!');
    print('Updated Completed Status: ${updatedTaskResult.isCompleted}');
    print('Updated Description: ${updatedTaskResult.description}');

    // Test retrieving the task
    print('Retrieving task...');
    final retrievedTask = await taskService.getTaskById(createdTask.id);
    print('✅ Task retrieved successfully!');
    print('Retrieved Title: ${retrievedTask.title}');
    print('Retrieved Completed Status: ${retrievedTask.isCompleted}');

    print('🎉 All task tests passed!');
  } catch (e) {
    print('❌ Error creating task: $e');
  }
}
