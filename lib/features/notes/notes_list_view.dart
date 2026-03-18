import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/app_models.dart';
import 'notes_controller.dart';

class NotesListView extends StatefulWidget {
  const NotesListView({super.key});

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<NotesController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);
    final filteredNotes = ctrl.notesByType(_selectedFilter);

    return Scaffold(
      appBar: AppBar(title: Text(lang.translate('tab_notes')), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All'),
                        _buildFilterChip('image', 'Image'),
                        _buildFilterChip('pdf', 'PDF'),
                        _buildFilterChip('text', 'Text'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _showAddOptions(context, ctrl),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(child: Text('No items in this section yet.'))
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(_iconForType(note.type))),
                          title: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(note.type.toUpperCase()),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(context, ctrl, note, value),
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'open', child: Text('Open')),
                              PopupMenuItem(value: 'rename', child: Text('Rename')),
                              PopupMenuItem(value: 'edit_text', child: Text('Edit Text')),
                              PopupMenuItem(value: 'share', child: Text('Share')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                          onTap: () => _viewNote(context, note),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (_) => setState(() => _selectedFilter = value),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.text_snippet;
    }
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    NotesController ctrl,
    NoteItem note,
    String action,
  ) async {
    switch (action) {
      case 'open':
        _viewNote(context, note);
        break;
      case 'rename':
        _showRenameDialog(context, ctrl, note);
        break;
      case 'edit_text':
        if (note.type == 'text') {
          _showTextEditor(context, ctrl, existingNote: note);
        }
        break;
      case 'share':
        await _shareNote(note);
        break;
      case 'delete':
        await ctrl.deleteNote(note.id);
        break;
    }
  }

  Future<void> _shareNote(NoteItem note) async {
    if (note.type == 'text') {
      await Share.share('${note.title}\n\n${note.content}');
      return;
    }

    final file = XFile(note.content);
    await Share.shareXFiles([file], text: note.title);
  }

  void _viewNote(BuildContext context, NoteItem note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: switch (note.type) {
              'image' => Image.file(File(note.content)),
              'pdf' => Text(note.content),
              _ => SelectableText(note.content),
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
              _showTextEditor(context, ctrl);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Add Image'),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (!mounted || pickedFile == null) return;
              await _savePickedFile(
                context,
                ctrl,
                type: 'image',
                path: pickedFile.path,
                defaultTitle: 'Image',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Add PDF'),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              final path = result?.files.single.path;
              if (!mounted || path == null) return;
              await _savePickedFile(
                context,
                ctrl,
                type: 'pdf',
                path: path,
                defaultTitle: result?.files.single.name ?? 'PDF',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _savePickedFile(
    BuildContext context,
    NotesController ctrl, {
    required String type,
    required String path,
    required String defaultTitle,
  }) async {
    final title = await _showTitlePrompt(context, defaultTitle);
    if (title == null || title.trim().isEmpty) return;
    await ctrl.addNote(title: title.trim(), type: type, content: path);
  }

  Future<String?> _showTitlePrompt(BuildContext context, String defaultTitle) async {
    final controller = TextEditingController(text: defaultTitle);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, NotesController ctrl, NoteItem note) {
    final controller = TextEditingController(text: note.title);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ctrl.renameNote(note.id, controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showTextEditor(BuildContext context, NotesController ctrl, {NoteItem? existingNote}) {
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNote == null ? 'Add Text Note' : 'Edit Text Note'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Text',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isEmpty || content.isEmpty) return;

              if (existingNote == null) {
                await ctrl.addNote(title: title, type: 'text', content: content);
              } else {
                await ctrl.updateTextNote(
                  id: existingNote.id,
                  title: title,
                  content: content,
                );
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: Text(existingNote == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
