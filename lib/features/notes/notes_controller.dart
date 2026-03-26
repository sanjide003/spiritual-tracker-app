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
    allFolders.sort((a, b) {
      if (a.id == defaultFolderId) return -1;
      if (b.id == defaultFolderId) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return allFolders;
  }

  NoteFolder? folderById(String folderId) => _foldersBox.get(folderId);

  int noteCountForFolder(String folderId) {
    return _notesBox.values.where((note) => note.folderId == folderId).length;
  }

  List<NoteItem> notesFor({
    required String folderId,
    required String filter,
    String searchQuery = '',
  }) {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final items = _notesBox.values.where((note) {
      final folderMatch = note.folderId == folderId;
      final typeMatch = filter == 'all' || note.type == filter;
      final queryMatch = normalizedQuery.isEmpty ||
          note.title.toLowerCase().contains(normalizedQuery) ||
          (note.type == 'text' && note.content.toLowerCase().contains(normalizedQuery));
      return folderMatch && typeMatch && queryMatch;
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
    if (trimmedName.isEmpty || _folderNameExists(trimmedName)) return null;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _foldersBox.put(id, NoteFolder(id: id, name: trimmedName));
    notifyListeners();
    return id;
  }

  Future<bool> renameFolder(String folderId, String name) async {
    final folder = _foldersBox.get(folderId);
    if (folder == null) return false;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;
    if (_folderNameExists(trimmedName, excludingId: folderId)) return false;
    folder.name = trimmedName;
    await folder.save();
    notifyListeners();
    return true;
  }

  Future<bool> deleteFolder(String folderId, {String? moveNotesToFolderId}) async {
    if (folderId == defaultFolderId) return false;
    final folder = _foldersBox.get(folderId);
    if (folder == null) return false;

    final targetFolderId = moveNotesToFolderId == null || moveNotesToFolderId == folderId
        ? defaultFolderId
        : moveNotesToFolderId;

    for (final note in _notesBox.values.where((note) => note.folderId == folderId)) {
      note.folderId = targetFolderId;
      await note.save();
    }

    await folder.delete();
    notifyListeners();
    return true;
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

  Future<void> moveNote(String id, String targetFolderId) async {
    final note = _notesBox.get(id);
    if (note == null || _foldersBox.get(targetFolderId) == null) return;
    note.folderId = targetFolderId;
    await note.save();
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

  bool _folderNameExists(String name, {String? excludingId}) {
    final normalized = name.trim().toLowerCase();
    return _foldersBox.values.any(
      (folder) => folder.id != excludingId && folder.name.trim().toLowerCase() == normalized,
    );
  }
}
