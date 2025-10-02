import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/data/models/task_model.dart';
import 'package:nextlead/providers/notification_provider.dart';
import 'package:nextlead/providers/task_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/components/bottom_nav_bar.dart';
import 'package:nextlead/ui/widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _currentIndex = 2;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadTasks();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // Handle navigation based on index
      switch (index) {
        case 0: // Dashboard
          Navigator.pushNamed(context, AppRoutes.dashboard);
          break;
        case 1: // Leads
          Navigator.pushNamed(context, AppRoutes.leads);
          break;
        case 2: // Tasks
          // Already on tasks screen
          break;
        case 3: // Notes
          Navigator.pushNamed(context, AppRoutes.notes);
          break;
        case 4: // Settings
          Navigator.pushNamed(context, AppRoutes.settings);
          break;
      }
    });
  }

  // Add delete task method
  void _deleteTask(BuildContext context, TaskProvider taskProvider,
      String taskId, String taskTitle) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content:
              Text('Are you sure you want to delete the task "$taskTitle"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                // Perform delete
                taskProvider.deleteTask(taskId).catchError((error) {
                  // Show error message if delete fails
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete task: $error'),
                        backgroundColor: AppColors.statusLost,
                      ),
                    );
                  }
                });
              },
              child: const Text(
                AppTexts.delete,
                style: TextStyle(color: AppColors.statusLost),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.tasksTitle),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to notifications screen
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.statusLost,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
            icon: Icon(
              _showCompleted ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(taskProvider.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: taskProvider.loadTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<Task> tasksToShow = _showCompleted
              ? taskProvider.completedTasks
              : taskProvider.upcomingTasks;

          if (tasksToShow.isEmpty) {
            return Center(
              child: Text(
                _showCompleted ? 'No completed tasks' : 'No upcoming tasks',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasksToShow.length,
            itemBuilder: (context, index) {
              final task = tasksToShow[index];
              return TaskTile(
                task: task,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.taskForm,
                    arguments: {
                      'task': task,
                      'leadId': task.leadId,
                    },
                  );
                },
                onCheckboxChanged: (value) {
                  // Handle task completion toggle
                  // Update the task with new completion status
                },
                onDelete: () => _deleteTask(context, taskProvider, task.id,
                    task.title), // Pass delete handler
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.taskForm,
            arguments: {
              'task': null, // null indicates new task
              'leadId': '', // This would need to be set to a specific lead ID
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
