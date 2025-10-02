import 'package:nextlead/data/models/note_model.dart';
import 'package:nextlead/data/services/airtable_service.dart';
import 'package:nextlead/data/services/note_service.dart';

void main() async {
  print('Testing Note Creation...');

  try {
    // Create services
    final airtableService = AirtableService();
    final noteService = NoteService(airtableService);

    // Create a test note
    final testNote = Note(
      id: 'test',
      leadId:
          'recGoT0ty2myavitM', // Using an existing lead ID from your Airtable
      content: 'This is a test note',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('Creating note...');
    final createdNote = await noteService.createNote(testNote);
    print('✅ Note created successfully!');
    print('Note ID: ${createdNote.id}');
    print('Note Content: ${createdNote.content}');
    print('Note Created At: ${createdNote.createdAt}');

    // Test updating the note
    final updatedNote = createdNote.copyWith(
      content: 'This is an updated test note',
    );

    print('Updating note...');
    final updatedNoteResult = await noteService.updateNote(updatedNote);
    print('✅ Note updated successfully!');
    print('Updated Content: ${updatedNoteResult.content}');

    // Test retrieving the note
    print('Retrieving note...');
    final retrievedNote = await noteService.getNoteById(createdNote.id);
    print('✅ Note retrieved successfully!');
    print('Retrieved Content: ${retrievedNote.content}');

    print('🎉 All note tests passed!');
  } catch (e) {
    print('❌ Error creating note: $e');
  }
}
