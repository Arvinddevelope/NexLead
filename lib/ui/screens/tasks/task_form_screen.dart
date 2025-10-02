import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/validators.dart';
import 'package:nextlead/data/models/task_model.dart';
import 'package:nextlead/providers/task_provider.dart';
import 'package:nextlead/ui/widgets/custom_button.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null for new task, provided for edit
  final String leadId; // Required for linking task to lead

  const TaskFormScreen({super.key, this.task, required this.leadId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    if (widget.task != null) {
      _titleController = TextEditingController(text: widget.task!.title);
      _descriptionController =
          TextEditingController(text: widget.task!.description);
      _dueDate = widget.task!.dueDate;
      _dueTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
      _isCompleted = widget.task!.isCompleted;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );

    if (picked != null && mounted) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  DateTime _combineDateAndTime() {
    return DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      try {
        final combinedDateTime = _combineDateAndTime();
        final now = DateTime.now();

        if (widget.task == null) {
          // Create new task
          final newTask = Task(
            id: '', // Will be assigned by backend
            leadId: widget.leadId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            dueDate: combinedDateTime,
            isCompleted: _isCompleted,
            createdAt: now,
            updatedAt: now,
          );

          await taskProvider.createTask(newTask);
        } else {
          // Update existing task
          final updatedTask = widget.task!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            dueDate: combinedDateTime,
            isCompleted: _isCompleted,
            updatedAt: now,
          );

          await taskProvider.updateTask(updatedTask);
        }

        if (mounted) {
          Navigator.pop(context); // Go back to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.statusLost,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? AppTexts.addTask : AppTexts.editTask),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: AppTexts.taskTitle,
                  hintText: 'Follow up with client',
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Title'),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: AppTexts.taskDescription,
                  hintText: 'Add details about the task...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Due Date
              ListTile(
                title: const Text(AppTexts.dueDate),
                subtitle: Text('${_dueDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Due Time
              ListTile(
                title: const Text('Due Time'),
                subtitle: Text(_dueTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),
              const SizedBox(height: 16),

              // Completed Status
              SwitchListTile(
                title: const Text('Completed'),
                value: _isCompleted,
                onChanged: (bool value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 24),

              // Save Button
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  return CustomButton(
                    text: AppTexts.save,
                    onPressed: taskProvider.isLoading ? () {} : _saveTask,
                    isLoading: taskProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
