import 'package:nextlead/data/models/note_model.dart';
import 'package:nextlead/data/services/note_service.dart';

class NoteRepository {
  final NoteService _noteService;

  NoteRepository(this._noteService);

  /// Get all notes for a lead
  Future<List<Note>> getNotesByLeadId(String leadId) async {
    return await _noteService.getNotesByLeadId(leadId);
  }

  /// Get note by ID
  Future<Note> getNoteById(String id) async {
    return await _noteService.getNoteById(id);
  }

  /// Create a new note
  Future<Note> createNote(Note note) async {
    return await _noteService.createNote(note);
  }

  /// Update an existing note
  Future<Note> updateNote(Note note) async {
    return await _noteService.updateNote(note);
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    return await _noteService.deleteNote(id);
  }
}
