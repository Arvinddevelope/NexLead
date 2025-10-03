import 'package:flutter/material.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/utils/helpers.dart';
import 'package:nextlead/data/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(bool?) onCheckboxChanged;
  final VoidCallback onDelete; // Add onDelete callback

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
    required this.onDelete, // Add onDelete parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onCheckboxChanged,
          activeColor: AppColors.primary,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              Helpers.formatDateTime(task.dueDate),
              style: TextStyle(
                fontSize: 12,
                color: task.isCompleted
                    ? AppColors.gray500
                    : (task.dueDate.isBefore(DateTime.now())
                        ? AppColors.statusLost
                        : AppColors.primary),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              onTap: onDelete,
              child: const Row(
                children: [
                  Icon(Icons.delete, color: AppColors.statusLost),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ), // Call onDelete when tapped
            ),
          ],
        ),
      ),
    );
  }
}
