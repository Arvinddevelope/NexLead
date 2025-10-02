import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/data/models/note_model.dart';
import 'package:nextlead/providers/notification_provider.dart';
import 'package:nextlead/providers/note_provider.dart';
import 'package:nextlead/routes/app_routes.dart';
import 'package:nextlead/ui/components/bottom_nav_bar.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  int _currentIndex = 3;
  final String _leadId =
      'recGoT0ty2myavitM'; // Using a real lead ID for testing

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      noteProvider.loadNotes(_leadId);
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
          Navigator.pushNamed(context, AppRoutes.tasks);
          break;
        case 3: // Notes
          // Already on notes screen
          break;
        case 4: // Settings
          Navigator.pushNamed(context, AppRoutes.settings);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.notesTitle),
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
            onPressed: _showAddNoteDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noteProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(noteProvider.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => noteProvider.loadNotes(_leadId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final notes = noteProvider.getNotesByLeadId(_leadId);

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notes yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddNoteDialog,
                    child: const Text('Add Your First Note'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notes.length} ${notes.length == 1 ? 'Note' : 'Notes'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddNoteDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Note'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _buildNoteCard(noteProvider, note);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildNoteCard(NoteProvider noteProvider, Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDeleteNote(noteProvider, note),
                  icon: const Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.red,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showEditNoteDialog(noteProvider, note),
                child: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Note'),
          content: TextField(
            controller: contentController,
            decoration: const InputDecoration(
              hintText: 'Enter your note here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                if (contentController.text.trim().isNotEmpty) {
                  final newNote = Note(
                    id: '',
                    leadId: _leadId,
                    content: contentController.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  noteProvider.createNote(newNote);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditNoteDialog(NoteProvider noteProvider, Note note) {
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: contentController,
            decoration: const InputDecoration(
              hintText: 'Enter your note here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () {
                if (contentController.text.trim().isNotEmpty) {
                  final updatedNote = note.copyWith(
                    content: contentController.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  noteProvider.updateNote(updatedNote);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteNote(NoteProvider noteProvider, Note note) {
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
                noteProvider.deleteNote(note.id, _leadId);
              },
              child: const Text(
                AppTexts.delete,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
