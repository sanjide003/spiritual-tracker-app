import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import 'notes_controller.dart';

class NoteEditView extends StatelessWidget {
  const NoteEditView({super.key, this.folderId = NotesController.defaultFolderId});

  final String folderId;

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final notesCtrl = Provider.of<NotesController>(context, listen: false);
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('note_edit_add')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                await notesCtrl.addTextNote(
                  folderId: folderId,
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: lang.translate('note_edit_hint_title'),
                border: InputBorder.none,
                hintStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: contentCtrl,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: lang.translate('note_edit_hint_body'),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
