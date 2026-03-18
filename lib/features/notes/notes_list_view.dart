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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<NotesController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);
    final folders = ctrl.folders;

    if (folders.isNotEmpty && !folders.any((folder) => folder.id == _selectedFolderId)) {
      _selectedFolderId = folders.first.id;
    }

    final filteredNotes = ctrl.notesFor(
      folderId: _selectedFolderId,
      filter: _selectedFilter,
      searchQuery: _searchQuery,
    );
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
                              onLongPress: () => _showFolderActions(context, ctrl, folder),
                              child: InputChip(
                                label: Text('${folder.name} (${ctrl.noteCountForFolder(folder.id)})'),
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
                  label: Text(lang.translate('notes_folder_button')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: lang.translate('notes_search_hint'),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', lang.translate('notes_filter_all')),
                        _buildFilterChip('image', lang.translate('notes_filter_image')),
                        _buildFilterChip('pdf', lang.translate('notes_filter_pdf')),
                        _buildFilterChip('text', lang.translate('notes_filter_text')),
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
                  lang.translateWithArgs('notes_current_folder', {'name': selectedFolder.name}),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          Expanded(
            child: filteredNotes.isEmpty
                ? _NotesEmptyState(
                    hasSearch: _searchQuery.trim().isNotEmpty,
                    selectedFilter: _selectedFilter,
                    folderName: selectedFolder?.name ?? lang.translate('notes_folder_button'),
                  )
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(_iconForType(note.type))),
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(_subtitleForNote(context, note)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(context, ctrl, note, value),
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'open', child: Text(_t(context, 'notes_menu_open'))),
                              PopupMenuItem(value: 'rename', child: Text(_t(context, 'notes_menu_rename'))),
                              PopupMenuItem(value: 'move', child: Text(_t(context, 'notes_menu_move'))),
                              if (note.type == 'text')
                                PopupMenuItem(value: 'edit_text', child: Text(_t(context, 'notes_menu_edit_text'))),
                              PopupMenuItem(value: 'share', child: Text(_t(context, 'notes_menu_share'))),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(_t(context, 'common_delete'), style: const TextStyle(color: Colors.red)),
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

  String _subtitleForNote(BuildContext context, NoteItem note) {
    if (note.type == 'text') return Provider.of<AppLanguageProvider>(context, listen: false).translate('notes_type_text');
    final sizeMb = note.fileSizeBytes / (1024 * 1024);
    final typeLabel = note.type == 'image'
        ? Provider.of<AppLanguageProvider>(context, listen: false).translate('notes_filter_image')
        : Provider.of<AppLanguageProvider>(context, listen: false).translate('notes_filter_pdf');
    return '$typeLabel • ${sizeMb.toStringAsFixed(2)} MB';
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
      case 'move':
        _showMoveDialog(context, ctrl, note);
        break;
      case 'edit_text':
        _showTextEditor(context, ctrl, existingNote: note);
        break;
      case 'share':
        await _shareNote(context, note);
        break;
      case 'delete':
        await _confirmDeleteNote(context, ctrl, note);
        break;
    }
  }

  Future<void> _shareNote(BuildContext context, NoteItem note) async {
    try {
      if (note.type == 'text') {
        await Share.share('${note.title}\n\n${note.content}');
        return;
      }

      final file = File(note.content);
      if (!await file.exists()) {
        if (context.mounted) {
          _showSnackBar(context, _t(context, 'notes_file_unavailable'));
        }
        return;
      }

      await Share.shareXFiles([XFile(note.content)], text: note.title);
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, _t(context, 'notes_share_failed'));
      }
    }
  }

  Future<void> _viewNote(BuildContext context, NoteItem note) async {
    if (note.type != 'text') {
      final file = File(note.content);
      if (!await file.exists()) {
        if (context.mounted) {
          _showSnackBar(context, _t(context, 'notes_file_missing'));
        }
        return;
      }
    }

    if (!context.mounted) return;

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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t(context, 'common_close'))),
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
            title: Text(_t(context, 'notes_add_text')),
            onTap: () {
              Navigator.pop(context);
              _showTextEditor(context, ctrl);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: Text(_t(context, 'notes_upload_image')),
            onTap: () async {
              Navigator.pop(context);
              try {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (!mounted || pickedFile == null) return;
                await _savePickedFile(
                  context,
                  ctrl,
                  type: 'image',
                  path: pickedFile.path,
                  defaultTitle: _t(context, 'notes_filter_image'),
                );
              } catch (_) {
                if (context.mounted) {
                  _showSnackBar(context, _t(context, 'notes_import_image_failed'));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(_t(context, 'notes_upload_pdf')),
            onTap: () async {
              Navigator.pop(context);
              try {
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
                  defaultTitle: result?.files.single.name ?? _t(context, 'notes_filter_pdf'),
                );
              } catch (_) {
                if (context.mounted) {
                  _showSnackBar(context, _t(context, 'notes_import_pdf_failed'));
                }
              }
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
    final title = await _showNamePrompt(context, defaultTitle, title: _t(context, 'notes_file_name'));
    if (!context.mounted || title == null || title.trim().isEmpty) return;

    try {
      await ctrl.importFile(
        folderId: _selectedFolderId,
        title: title.trim(),
        type: type,
        sourcePath: path,
      );
      if (context.mounted) {
        _showSnackBar(context, _t(context, 'notes_added_success', {'type': type.toUpperCase()}));
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, _t(context, 'notes_save_failed'));
      }
    }
  }

  Future<String?> _showNamePrompt(BuildContext context, String defaultValue, {required String title}) async {
    final controller = TextEditingController(text: defaultValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: _t(context, 'common_name')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t(context, 'common_cancel'))),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(_t(context, 'common_save')),
          ),
        ],
      ),
    );
  }

  Future<void> _showFolderActions(BuildContext context, NotesController ctrl, NoteFolder folder) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(_t(context, 'notes_rename_folder')),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            if (folder.id != NotesController.defaultFolderId)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(_t(context, 'notes_delete_folder'), style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (!context.mounted || action == null) return;
    if (action == 'rename') {
      _showFolderDialog(context, ctrl, existingFolder: folder);
    } else if (action == 'delete') {
      await _showDeleteFolderDialog(context, ctrl, folder);
    }
  }

  void _showFolderDialog(BuildContext context, NotesController ctrl, {NoteFolder? existingFolder}) {
    final controller = TextEditingController(text: existingFolder?.name ?? '');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingFolder == null ? _t(context, 'notes_create_folder') : _t(context, 'notes_rename_folder')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: _t(context, 'notes_folder_name')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t(context, 'common_cancel'))),
          FilledButton(
            onPressed: () async {
              final trimmedName = controller.text.trim();
              if (trimmedName.isEmpty) {
                _showSnackBar(context, _t(context, 'notes_folder_empty_error'));
                return;
              }

              bool success = false;
              if (existingFolder == null) {
                final newFolderId = await ctrl.createFolder(trimmedName);
                success = newFolderId != null;
                if (context.mounted && newFolderId != null) {
                  setState(() => _selectedFolderId = newFolderId);
                }
              } else {
                success = await ctrl.renameFolder(existingFolder.id, trimmedName);
              }

              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
              } else {
                _showSnackBar(context, _t(context, 'notes_folder_exists_error'));
              }
            },
            child: Text(existingFolder == null ? _t(context, 'notes_create_folder') : _t(context, 'common_update')),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteFolderDialog(BuildContext context, NotesController ctrl, NoteFolder folder) async {
    final availableTargets = ctrl.folders.where((item) => item.id != folder.id).toList();
    String targetFolderId = NotesController.defaultFolderId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_t(context, 'notes_delete_folder_title', {'name': folder.name})),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t(context, 'notes_delete_folder_message')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: targetFolderId,
                decoration: InputDecoration(labelText: _t(context, 'notes_move_notes_to')),
                items: availableTargets
                    .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => targetFolderId = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(_t(context, 'common_cancel'))),
            FilledButton(
              onPressed: () async {
                final deleted = await ctrl.deleteFolder(folder.id, moveNotesToFolderId: targetFolderId);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                if (deleted) {
                  setState(() => _selectedFolderId = targetFolderId);
                  _showSnackBar(context, _t(context, 'notes_folder_deleted'));
                }
              },
              child: Text(_t(context, 'common_delete')),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, NotesController ctrl, NoteItem note) {
    final controller = TextEditingController(text: note.title);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t(context, 'common_rename')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: _t(context, 'common_title')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t(context, 'common_cancel'))),
          FilledButton(
            onPressed: () async {
              await ctrl.renameNote(note.id, controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(_t(context, 'common_update')),
          ),
        ],
      ),
    );
  }

  Future<void> _showMoveDialog(BuildContext context, NotesController ctrl, NoteItem note) async {
    final folders = ctrl.folders.where((folder) => folder.id != note.folderId).toList();
    if (folders.isEmpty) {
      _showSnackBar(context, _t(context, 'notes_create_folder_before_move'));
      return;
    }

    String selectedFolderId = folders.first.id;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_t(context, 'notes_move_item_title')),
          content: DropdownButtonFormField<String>(
            value: selectedFolderId,
            decoration: InputDecoration(labelText: _t(context, 'notes_choose_folder')),
            items: folders
                .map((folder) => DropdownMenuItem(value: folder.id, child: Text(folder.name)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setDialogState(() => selectedFolderId = value);
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(_t(context, 'common_cancel'))),
            FilledButton(
              onPressed: () async {
                await ctrl.moveNote(note.id, selectedFolderId);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                _showSnackBar(context, _t(context, 'notes_item_moved'));
              },
              child: Text(_t(context, 'common_move')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteNote(BuildContext context, NotesController ctrl, NoteItem note) async {
    final deleteConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_t(context, 'notes_delete_item_title')),
            content: Text(_t(context, 'notes_delete_item_message', {'title': note.title})),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_t(context, 'common_cancel'))),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_t(context, 'common_delete')),
              ),
            ],
          ),
        ) ??
        false;

    if (!deleteConfirmed) return;
    await ctrl.deleteNote(note.id);
    if (context.mounted) {
      _showSnackBar(context, _t(context, 'notes_item_deleted'));
    }
  }

  void _showTextEditor(BuildContext context, NotesController ctrl, {NoteItem? existingNote}) {
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNote == null ? _t(context, 'notes_add_text') : _t(context, 'notes_edit_text_title')),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: _t(context, 'common_title')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: _t(context, 'common_text'),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t(context, 'common_cancel'))),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isEmpty || content.isEmpty) {
                _showSnackBar(context, _t(context, 'notes_title_and_text_required'));
                return;
              }

              if (existingNote == null) {
                await ctrl.addTextNote(folderId: _selectedFolderId, title: title, content: content);
              } else {
                await ctrl.updateTextNote(id: existingNote.id, title: title, content: content);
              }

              if (context.mounted) {
                Navigator.pop(context);
                _showSnackBar(context, existingNote == null ? _t(context, 'notes_text_added') : _t(context, 'notes_text_updated'));
              }
            },
            child: Text(existingNote == null ? _t(context, 'common_add') : _t(context, 'common_save')),
          ),
        ],
      ),
    );
  }

  String _t(BuildContext context, String key, [Map<String, String> args = const {}]) {
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);
    return lang.translateWithArgs(key, args);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NotesEmptyState extends StatelessWidget {
  const _NotesEmptyState({
    required this.hasSearch,
    required this.selectedFilter,
    required this.folderName,
  });

  final bool hasSearch;
  final String selectedFilter;
  final String folderName;

  @override
  Widget build(BuildContext context) {
        final lang = Provider.of<AppLanguageProvider>(context, listen: false);
    final message = hasSearch
        ? lang.translateWithArgs('notes_empty_search', {'folder': folderName})
        : switch (selectedFilter) {
            'image' => lang.translateWithArgs('notes_empty_image', {'folder': folderName}),
            'pdf' => lang.translateWithArgs('notes_empty_pdf', {'folder': folderName}),
            'text' => lang.translateWithArgs('notes_empty_text', {'folder': folderName}),
            _ => lang.translateWithArgs('notes_empty_all', {'folder': folderName}),
          };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
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