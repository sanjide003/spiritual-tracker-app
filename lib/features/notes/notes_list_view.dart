// 📂 File: lib/features/notes/notes_list_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'notes_controller.dart';
import '../../core/localization/app_localizations.dart';

class NotesListView extends StatelessWidget {
  const NotesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<NotesController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.translate('tab_notes')), centerTitle: true),
      body: ctrl.notes.isEmpty
          ? const Center(child: Text('No notes or files added.'))
          : ListView.builder(
              itemCount: ctrl.notes.length,
              itemBuilder: (context, index) {
                final note = ctrl.notes[index];
                IconData icon = note.type == 'image' ? Icons.image : note.type == 'pdf' ? Icons.picture_as_pdf : Icons.text_snippet;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(icon)),
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.type.toUpperCase()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ctrl.deleteNote(note.id),
                    ),
                    onTap: () => _viewNote(context, note), // നോട്ട്/ഫയൽ കാണാൻ
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context, ctrl),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ഫയൽ കാണിക്കുന്ന സംവിധാനം (Viewing)
  void _viewNote(BuildContext context, dynamic note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: note.type == 'image'
            ? Image.file(File(note.content)) // ഗാലറിയിൽ നിന്നുള്ള ഫോട്ടോ കാണിക്കുന്നു
            : note.type == 'pdf'
                ? const Text('PDF Viewer is launching...') // PDF പാക്കേജ് ഉപയോഗിച്ച് കാണിക്കാം
                : Text(note.content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showAddOptions(BuildContext context, NotesController ctrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.text_fields), title: const Text('Add Text Note'),
            onTap: () {
              Navigator.pop(context);
              ctrl.addNote('Text Note', 'text', 'Enter your notes here...');
            },
          ),
          ListTile(
            leading: const Icon(Icons.image), title: const Text('Add Image'),
            onTap: () async {
              Navigator.pop(context);
              // ഇമേജ് പിക്കർ പ്രവർത്തിക്കുന്നു
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) ctrl.addNote('My Image', 'image', pickedFile.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf), title: const Text('Add PDF'),
            onTap: () async {
              Navigator.pop(context);
              // ഫയൽ പിക്കർ പ്രവർത്തിക്കുന്നു
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
              if (result != null) ctrl.addNote('My PDF', 'pdf', result.files.single.path!);
            },
          ),
        ],
      )
    );
  }
}