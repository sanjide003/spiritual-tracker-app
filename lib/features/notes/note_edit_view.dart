import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notes_controller.dart';

class NoteEditView extends StatelessWidget {
  const NoteEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final notesCtrl = Provider.of<NotesController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                await notesCtrl.addNote(
                  title: titleCtrl.text,
                  type: 'text',
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
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: contentCtrl,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Type your thoughts here...',
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
