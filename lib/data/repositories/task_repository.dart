import 'package:nextlead/data/models/task_model.dart';
import 'package:nextlead/data/services/task_service.dart';

class TaskRepository {
  final TaskService _taskService;

  TaskRepository(this._taskService);

  /// Get all tasks for a lead
  Future<List<Task>> getTasksByLeadId(String leadId) async {
    return await _taskService.getTasksByLeadId(leadId);
  }

  /// Get all tasks (for dashboard)
  Future<List<Task>> getAllTasks() async {
    return await _taskService.getAllTasks();
  }

  /// Get task by ID
  Future<Task> getTaskById(String id) async {
    return await _taskService.getTaskById(id);
  }

  /// Create a new task
  Future<Task> createTask(Task task) async {
    return await _taskService.createTask(task);
  }

  /// Update an existing task
  Future<Task> updateTask(Task task) async {
    return await _taskService.updateTask(task);
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    return await _taskService.deleteTask(id);
  }
}
