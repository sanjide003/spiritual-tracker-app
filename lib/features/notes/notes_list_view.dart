// 📂 File: lib/features/notes/notes_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notes_controller.dart';
import '../../core/localization/app_localizations.dart';
import 'note_edit_view.dart'; // ഇത് താഴെ കൊടുത്തിട്ടുണ്ട്

class NotesListView extends StatelessWidget {
  const NotesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final notesCtrl = Provider.of<NotesController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_notes')),
        centerTitle: true,
      ),
      body: notesCtrl.notes.isEmpty
          ? const Center(child: Text('No notes added yet.'))
          : ListView.builder(
              itemCount: notesCtrl.notes.length,
              itemBuilder: (context, index) {
                final note = notesCtrl.notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => notesCtrl.deleteNote(index),
                    ),
                    onTap: () {
                      // ഇത് ഭാവിയിൽ Read-Only View ലേക്ക് പോകാൻ ഉപയോഗിക്കാം
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}