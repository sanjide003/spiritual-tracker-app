// 📂 File: lib/features/notes/notes_controller.dart

import 'package:flutter/material.dart';

class NoteItem {
  String id;      // പുതിയതായി ആഡ് ചെയ്തു
  String title;
  String content;
  String type;    // പുതിയതായി ആഡ് ചെയ്തു (text, image, pdf)

  NoteItem({required this.id, required this.title, required this.content, required this.type});
}

class NotesController extends ChangeNotifier {
  final List<NoteItem> notes = [];

  void addNote(String title, String type, String content) {
    notes.add(NoteItem(
      id: DateTime.now().toString(), 
      title: title, 
      type: type, 
      content: content
    ));
    notifyListeners();
  }

  void deleteNote(String id) {
    notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}