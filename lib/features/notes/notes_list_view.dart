// 📂 File: lib/features/notes/notes_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notes_controller.dart';
import '../../core/localization/app_localizations.dart';

class NotesListView extends StatelessWidget {
  const NotesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<NotesController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_notes')),
        centerTitle: true,
      ),
      body: ctrl.notes.isEmpty
          ? const Center(child: Text('No notes or files added.'))
          : ListView.builder(
              itemCount: ctrl.notes.length,
              itemBuilder: (context, index) {
                final note = ctrl.notes[index];
                IconData icon;
                if (note.type == 'image') icon = Icons.image;
                else if (note.type == 'pdf') icon = Icons.picture_as_pdf;
                else icon = Icons.text_snippet;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(icon)),
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.type.toUpperCase()),
                    // വലതുവശത്തെ 3-ഡോട്ട് മെനു
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          // Edit logic
                        } else if (val == 'delete') {
                          ctrl.deleteNote(note.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                    onTap: () {
                      // ഫയൽ വ്യൂ ചെയ്യാനുള്ള ലോജിക് ഇവിടെ വരും
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing feature coming soon')));
                    },
                  ),
                );
              },
            ),
      // ടെക്സ്റ്റ്, ഇമേജ്, PDF ആഡ് ചെയ്യാൻ
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           _showAddOptions(context, ctrl);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context, NotesController ctrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Add Text Note'),
            onTap: () {
              Navigator.pop(context);
              ctrl.addNote('New Text Note', 'text', 'Some content');
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Add Image'),
            onTap: () {
              Navigator.pop(context);
              ctrl.addNote('Image Attachment', 'image', 'path/to/image'); // Image picker ലോജിക് പിന്നീട് വരും
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Add PDF'),
            onTap: () {
              Navigator.pop(context);
              ctrl.addNote('PDF Document', 'pdf', 'path/to/pdf'); // PDF picker ലോജിക് പിന്നീട് വരും
            },
          ),
        ],
      )
    );
  }
}