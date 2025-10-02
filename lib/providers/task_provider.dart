import 'package:flutter/material.dart';
import 'package:nextlead/data/models/task_model.dart';
import 'package:nextlead/data/repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  TaskProvider(this._taskRepository);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return (taskDate.isAtSameMomentAs(today) || taskDate.isAfter(today)) &&
          taskDate.isBefore(tomorrow) &&
          !task.isCompleted;
    }).toList();
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(today) && !task.isCompleted;
    }).toList();
  }

  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> getTasksByLeadId(String leadId) {
    return _tasks.where((task) => task.leadId == leadId).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _tasks = await _taskRepository.getAllTasks();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Task> getTaskById(String id) async {
    try {
      return await _taskRepository.getTaskById(id);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> createTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newTask = await _taskRepository.createTask(task);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedTask = await _taskRepository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _taskRepository.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
