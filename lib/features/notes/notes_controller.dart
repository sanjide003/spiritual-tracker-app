import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/models/app_models.dart';
import '../../services/database_service.dart';

class NotesController extends ChangeNotifier {
  final Box<NoteItem> _notesBox = Hive.box<NoteItem>(DatabaseService.notesBoxName);
  final Box<NoteFolder> _foldersBox = Hive.box<NoteFolder>(DatabaseService.noteFoldersBoxName);

  static const String defaultFolderId = 'general-folder';

  NotesController() {
    _ensureDefaultFolder();
  }

  List<NoteFolder> get folders {
    final allFolders = _foldersBox.values.toList();
    allFolders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return allFolders;
  }

  List<NoteItem> notesFor({required String folderId, required String filter}) {
    final items = _notesBox.values.where((note) {
      final folderMatch = note.folderId == folderId;
      final typeMatch = filter == 'all' || note.type == filter;
      return folderMatch && typeMatch;
    }).toList();

    items.sort((a, b) => b.id.compareTo(a.id));
    return items;
  }

  Future<void> _ensureDefaultFolder() async {
    if (_foldersBox.get(defaultFolderId) != null) return;
    await _foldersBox.put(
      defaultFolderId,
      NoteFolder(id: defaultFolderId, name: 'General'),
    );
    notifyListeners();
  }

  Future<String?> createFolder(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return null;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _foldersBox.put(id, NoteFolder(id: id, name: trimmedName));
    notifyListeners();
    return id;
  }

  Future<void> renameFolder(String folderId, String name) async {
    final folder = _foldersBox.get(folderId);
    if (folder == null) return;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    folder.name = trimmedName;
    await folder.save();
    notifyListeners();
  }

  Future<void> addTextNote({
    required String folderId,
    required String title,
    required String content,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final note = NoteItem(
      id: id,
      title: title.trim(),
      content: content.trim(),
      type: 'text',
      folderId: folderId,
    );
    await _notesBox.put(id, note);
    notifyListeners();
  }

  Future<void> importFile({
    required String folderId,
    required String title,
    required String type,
    required String sourcePath,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final appDocDir = await getApplicationDocumentsDirectory();
    final folderDir = Directory(p.join(appDocDir.path, 'notes_storage', folderId));
    await folderDir.create(recursive: true);

    final extension = p.extension(sourcePath);
    final targetPath = p.join(folderDir.path, '$id$extension');
    final sourceFile = File(sourcePath);
    final copiedFile = await sourceFile.copy(targetPath);
    final size = await copiedFile.length();

    final note = NoteItem(
      id: id,
      title: title.trim(),
      content: copiedFile.path,
      type: type,
      folderId: folderId,
      fileSizeBytes: size,
    );

    await _notesBox.put(id, note);
    notifyListeners();
  }

  Future<void> renameNote(String id, String newTitle) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    final trimmedTitle = newTitle.trim();
    if (trimmedTitle.isEmpty) return;
    note.title = trimmedTitle;
    await note.save();
    notifyListeners();
  }

  Future<void> updateTextNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    note
      ..title = title.trim()
      ..content = content.trim();
    await note.save();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    final note = _notesBox.get(id);
    if (note == null) return;
    if (note.type != 'text') {
      final file = File(note.content);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _notesBox.delete(id);
    notifyListeners();
  }
}
