import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/helpers.dart';
import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/providers/lead_provider.dart';
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
  late Lead _currentLead;

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
    // Load notes and tasks for this lead
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      noteProvider.loadNotes(_currentLead.id);
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
          title: Text(_currentLead.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.leadForm,
                  arguments: _currentLead,
                );

                // If the form was saved successfully, refresh the lead data
                if (result == true && mounted) {
                  // Reload the lead data from the provider
                  final leadProvider =
                      Provider.of<LeadProvider>(context, listen: false);
                  try {
                    final updatedLead =
                        await leadProvider.getLeadById(_currentLead.id);
                    // Update the current lead state
                    if (mounted) {
                      setState(() {
                        _currentLead = updatedLead;
                      });
                    }
                  } catch (e) {
                    // Handle error
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to refresh lead data: $e'),
                          backgroundColor: AppColors.statusLost,
                        ),
                      );
                    }
                  }
                }
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
              color: _getStatusColor(_currentLead.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(_currentLead.status),
                  size: 16,
                  color: AppColors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _currentLead.status,
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
          if (_currentLead.contactName != null &&
              _currentLead.contactName!.isNotEmpty)
            _buildInfoRow('Contact Name', _currentLead.contactName!),
          _buildInfoRow('Company', _currentLead.company),
          _buildInfoRow('Email', _currentLead.email),
          _buildInfoRow('Phone', _currentLead.phone),
          _buildInfoRow('Source', _currentLead.source),

          const SizedBox(height: 20),

          // Communication Features
          if (_currentLead.phone.isNotEmpty || _currentLead.email.isNotEmpty)
            CommunicationFeatures(
              phoneNumber: _currentLead.phone,
              email: _currentLead.email,
              leadName: _currentLead.name,
            ),
          if (_currentLead.phone.isNotEmpty || _currentLead.email.isNotEmpty)
            const SizedBox(height: 20),

          // Location Information
          if (_currentLead.latitude != null && _currentLead.longitude != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_currentLead.locationAddress != null &&
                    _currentLead.locationAddress!.isNotEmpty)
                  _buildInfoRow('Address', _currentLead.locationAddress!),
                _buildInfoRow('Latitude', _currentLead.latitude.toString()),
                _buildInfoRow('Longitude', _currentLead.longitude.toString()),
                const SizedBox(height: 16),
              ],
            ),

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
              'Created', Helpers.formatDateTime(_currentLead.createdAt)),
          _buildInfoRow(
              'Updated', Helpers.formatDateTime(_currentLead.updatedAt)),
          if (_currentLead.nextFollowUp != null)
            _buildInfoRow('Next Follow-up',
                Helpers.formatDateTime(_currentLead.nextFollowUp!)),

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
              _currentLead.notes.isEmpty ? 'No notes' : _currentLead.notes,
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
        final notes = noteProvider.getNotesByLeadId(_currentLead.id);

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
        final tasks = taskProvider.getTasksByLeadId(_currentLead.id);

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
                noteProvider.deleteNote(noteId, _currentLead.id);
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
    String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Add country code 91 if not already present and number length suggests Indian number
    // Indian mobile numbers are 10 digits, so if we have 10 digits, add 91 prefix
    if (cleanPhoneNumber.length == 10) {
      cleanPhoneNumber = '91$cleanPhoneNumber';
    }

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
