// 📂 File: lib/features/notes/notes_list_view.dart
// നാലാമത്തെ ടാബ് (നോട്ട്സ് & ജേണൽ)

import 'package:flutter/material.dart';

class NotesListView extends StatelessWidget {
  const NotesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Journal'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Notes and Attachments go here',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}