// 📂 File: lib/features/notes/notes_controller.dart

import 'package:flutter/material.dart';

class NoteItem {
  String title;
  String content;

  NoteItem({required this.title, required this.content});
}

class NotesController extends ChangeNotifier {
  final List<NoteItem> notes = [];

  void addNote(String title, String content) {
    notes.add(NoteItem(title: title, content: content));
    notifyListeners();
  }

  void deleteNote(int index) {
    notes.removeAt(index);
    notifyListeners();
  }
}