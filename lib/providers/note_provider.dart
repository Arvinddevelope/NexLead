import 'package:flutter/material.dart';
import 'package:nextlead/data/models/note_model.dart';
import 'package:nextlead/data/repositories/note_repository.dart';

class NoteProvider with ChangeNotifier {
  final NoteRepository _noteRepository;

  final Map<String, List<Note>> _notes = {}; // leadId -> List<Note>
  bool _isLoading = false;
  String _errorMessage = '';

  NoteProvider(this._noteRepository);

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<Note> getNotesByLeadId(String leadId) {
    return _notes[leadId] ?? [];
  }

  Future<void> loadNotes(String leadId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final notes = await _noteRepository.getNotesByLeadId(leadId);
      _notes[leadId] = notes;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Note> getNoteById(String id) async {
    try {
      return await _noteRepository.getNoteById(id);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> createNote(Note note) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newNote = await _noteRepository.createNote(note);
      if (_notes.containsKey(note.leadId)) {
        _notes[note.leadId]!.add(newNote);
      } else {
        _notes[note.leadId] = [newNote];
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

  Future<void> updateNote(Note note) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedNote = await _noteRepository.updateNote(note);
      if (_notes.containsKey(note.leadId)) {
        final index = _notes[note.leadId]!.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[note.leadId]![index] = updatedNote;
        }
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

  Future<void> deleteNote(String id, String leadId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _noteRepository.deleteNote(id);
      if (_notes.containsKey(leadId)) {
        _notes[leadId]!.removeWhere((note) => note.id == id);
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
}
