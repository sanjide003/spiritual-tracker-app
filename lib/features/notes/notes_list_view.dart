import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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
  String _selectedFolderId = NotesController.defaultFolderId;

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<NotesController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);
    final folders = ctrl.folders;

    if (folders.isNotEmpty && !folders.any((folder) => folder.id == _selectedFolderId)) {
      _selectedFolderId = folders.first.id;
    }

    final filteredNotes = ctrl.notesFor(folderId: _selectedFolderId, filter: _selectedFilter);
    final selectedFolder = folders.where((folder) => folder.id == _selectedFolderId).firstOrNull;

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
                        for (final folder in folders)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onLongPress: () => _showFolderDialog(context, ctrl, existingFolder: folder),
                              child: InputChip(
                                label: Text(folder.name),
                                selected: folder.id == _selectedFolderId,
                                onSelected: (_) => setState(() => _selectedFolderId = folder.id),
                                onPressed: () => setState(() => _selectedFolderId = folder.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _showFolderDialog(context, ctrl),
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text('Folder'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: selectedFolder == null ? null : () => _showAddOptions(context, ctrl),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          if (selectedFolder != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Folder: ${selectedFolder.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(child: Text('No items in this folder yet.'))
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(_iconForType(note.type))),
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(_subtitleForNote(note)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(context, ctrl, note, value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'open', child: Text('Open')),
                              const PopupMenuItem(value: 'rename', child: Text('Rename')),
                              if (note.type == 'text')
                                const PopupMenuItem(value: 'edit_text', child: Text('Edit Text')),
                              const PopupMenuItem(value: 'share', child: Text('Share')),
                              const PopupMenuItem(
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

  String _subtitleForNote(NoteItem note) {
    if (note.type == 'text') return 'TEXT';
    final sizeMb = note.fileSizeBytes / (1024 * 1024);
    return '${note.type.toUpperCase()} • ${sizeMb.toStringAsFixed(2)} MB';
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
        _showTextEditor(context, ctrl, existingNote: note);
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

    await Share.shareXFiles([XFile(note.content)], text: note.title);
  }

  void _viewNote(BuildContext context, NoteItem note) {
    if (note.type == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _PdfPreviewPage(note: note)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: switch (note.type) {
              'image' => Image.file(File(note.content)),
              _ => SelectableText(note.content),
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
            title: const Text('Upload Image'),
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
            title: const Text('Upload PDF'),
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
    final title = await _showNamePrompt(context, defaultTitle, title: 'File Name');
    if (title == null || title.trim().isEmpty) return;
    await ctrl.importFile(
      folderId: _selectedFolderId,
      title: title.trim(),
      type: type,
      sourcePath: path,
    );
  }

  Future<String?> _showNamePrompt(BuildContext context, String defaultValue, {required String title}) async {
    final controller = TextEditingController(text: defaultValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFolderDialog(BuildContext context, NotesController ctrl, {NoteFolder? existingFolder}) {
    final controller = TextEditingController(text: existingFolder?.name ?? '');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingFolder == null ? 'Create Folder' : 'Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Folder name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (existingFolder == null) {
                final newFolderId = await ctrl.createFolder(controller.text);
                if (context.mounted && newFolderId != null) {
                  setState(() => _selectedFolderId = newFolderId);
                }
              } else {
                await ctrl.renameFolder(existingFolder.id, controller.text);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(existingFolder == null ? 'Create' : 'Update'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ctrl.renameNote(note.id, controller.text);
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isEmpty || content.isEmpty) return;

              if (existingNote == null) {
                await ctrl.addTextNote(folderId: _selectedFolderId, title: title, content: content);
              } else {
                await ctrl.updateTextNote(id: existingNote.id, title: title, content: content);
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

class _PdfPreviewPage extends StatelessWidget {
  const _PdfPreviewPage({required this.note});

  final NoteItem note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: PDFView(filePath: note.content),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
