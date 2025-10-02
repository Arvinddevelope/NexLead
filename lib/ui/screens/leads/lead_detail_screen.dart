import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/helpers.dart';
import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/providers/note_provider.dart';
import 'package:nextlead/providers/task_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/widgets/note_tile.dart';
import 'package:nextlead/ui/widgets/task_tile.dart';

class LeadDetailScreen extends StatefulWidget {
  final Lead lead;

  const LeadDetailScreen({super.key, required this.lead});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load notes and tasks for this lead
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      noteProvider.loadNotes(widget.lead.id);
      taskProvider.loadTasks(); // This will load all tasks, we'll filter in UI
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return AppColors.statusNew;
      case 'Contacted':
        return AppColors.statusContacted;
      case 'Qualified':
        return AppColors.statusQualified;
      case 'Converted':
        return AppColors.statusConverted;
      case 'Lost':
        return AppColors.statusLost;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'New':
        return Icons.new_releases;
      case 'Contacted':
        return Icons.phone_in_talk;
      case 'Qualified':
        return Icons.check_circle;
      case 'Converted':
        return Icons.stars;
      case 'Lost':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lead.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.leadForm,
                  arguments: widget.lead,
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Notes'),
              Tab(text: 'Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Details Tab
            _buildDetailsTab(),
            // Notes Tab
            _buildNotesTab(),
            // Tasks Tab
            _buildTasksTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.lead.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(widget.lead.status),
                  size: 16,
                  color: AppColors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.lead.status,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contact Information
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.lead.contactName != null &&
              widget.lead.contactName!.isNotEmpty)
            _buildInfoRow('Contact Name', widget.lead.contactName!),
          _buildInfoRow('Company', widget.lead.company),
          _buildInfoRow('Email', widget.lead.email),
          _buildInfoRow('Phone', widget.lead.phone),
          _buildInfoRow('Source', widget.lead.source),

          const SizedBox(height: 20),

          // Communication Features
          if (widget.lead.phone.isNotEmpty || widget.lead.email.isNotEmpty)
            CommunicationFeatures(
              phoneNumber: widget.lead.phone,
              email: widget.lead.email,
              leadName: widget.lead.name,
            ),
          if (widget.lead.phone.isNotEmpty || widget.lead.email.isNotEmpty)
            const SizedBox(height: 20),

          // Dates
          const Text(
            'Dates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
              'Created', Helpers.formatDateTime(widget.lead.createdAt)),
          _buildInfoRow(
              'Updated', Helpers.formatDateTime(widget.lead.updatedAt)),
          if (widget.lead.nextFollowUp != null)
            _buildInfoRow('Next Follow-up',
                Helpers.formatDateTime(widget.lead.nextFollowUp!)),

          const SizedBox(height: 20),

          // Notes
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Text(
              widget.lead.notes.isEmpty ? 'No notes' : widget.lead.notes,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final notes = noteProvider.getNotesByLeadId(widget.lead.id);

        if (noteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notes.isEmpty) {
          return const Center(
            child: Text('No notes yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteTile(
              note: note,
              onTap: () {
                // Handle note edit
              },
              onDelete: () {
                // Handle note delete
                _confirmDeleteNote(noteProvider, note.id);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTasksTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.getTasksByLeadId(widget.lead.id);

        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tasks.isEmpty) {
          return const Center(
            child: Text('No tasks yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskTile(
              task: task,
              onTap: () {
                // Handle task edit
              },
              onCheckboxChanged: (value) {
                // Handle task completion toggle
              },
              onDelete: () {
                // Handle task deletion
              },
            );
          },
        );
      },
    );
  }

  void _confirmDeleteNote(NoteProvider noteProvider, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                noteProvider.deleteNote(noteId, widget.lead.id);
              },
              child: const Text(AppTexts.delete),
            ),
          ],
        );
      },
    );
  }
}

class CommunicationFeatures extends StatelessWidget {
  final String phoneNumber;
  final String email;
  final String leadName;

  const CommunicationFeatures({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.leadName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Lead',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (phoneNumber.isNotEmpty)
                _buildCommunicationButton(
                  context: context,
                  icon: Icons.call,
                  label: 'Call',
                  color: AppColors.primary,
                  onTap: () => _launchCaller(context, phoneNumber),
                ),
              if (phoneNumber.isNotEmpty)
                _buildCommunicationButton(
                  context: context,
                  icon: Icons.message,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onTap: () => _launchWhatsApp(
                      context, phoneNumber, _getWhatsAppMessage(leadName)),
                ),
              if (email.isNotEmpty)
                _buildCommunicationButton(
                  context: context,
                  icon: Icons.email,
                  label: 'Email',
                  color: Colors.red,
                  onTap: () => _launchEmail(context, email,
                      _getEmailSubject(leadName), _getEmailBody(leadName)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _launchCaller(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await launchUrl(launchUri)) {
        // Successfully launched
      } else {
        // Handle error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: AppColors.statusLost,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching phone dialer: $e'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(
      BuildContext context, String phoneNumber, String message) async {
    // Remove any non-digit characters from phone number
    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: cleanPhoneNumber,
      queryParameters: {'text': message},
    );
    try {
      if (await launchUrl(launchUri)) {
        // Successfully launched
      } else {
        // Handle error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch WhatsApp'),
              backgroundColor: AppColors.statusLost,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching WhatsApp: $e'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(
      BuildContext context, String email, String subject, String body) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    try {
      if (await launchUrl(launchUri)) {
        // Successfully launched
      } else {
        // Handle error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch email client'),
              backgroundColor: AppColors.statusLost,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching email client: $e'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
    }
  }

  String _getWhatsAppMessage(String leadName) {
    return 'Hello $leadName, I wanted to follow up on our discussion.';
  }

  String _getEmailSubject(String leadName) {
    return 'Follow-up on our discussion - $leadName';
  }

  String _getEmailBody(String leadName) {
    return 'Hi $leadName,\n\nI hope this email finds you well. I wanted to follow up on our recent discussion.\n\nBest regards,\n[Your Name]';
  }
}
