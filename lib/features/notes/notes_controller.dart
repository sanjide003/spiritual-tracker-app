import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/app_models.dart';

class NotesController extends ChangeNotifier {
  final Box<NoteItem> _notesBox = Hive.box<NoteItem>('notesBox');

  List<NoteItem> get notes {
    final items = _notesBox.values.toList();
    items.sort((a, b) => b.id.compareTo(a.id));
    return items;
  }

  List<NoteItem> notesByType(String filter) {
    if (filter == 'all') return notes;
    return notes.where((note) => note.type == filter).toList();
  }

  Future<void> addNote({
    required String title,
    required String type,
    required String content,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final note = NoteItem(
      id: id,
      title: title,
      content: content,
      type: type,
    );
    await _notesBox.put(id, note);
    notifyListeners();
  }

  Future<void> renameNote(String id, String newTitle) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    note.title = newTitle;
    await note.save();
    notifyListeners();
  }

  Future<void> updateTextNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    note
      ..title = title
      ..content = content;
    await note.save();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
    notifyListeners();
  }
}
