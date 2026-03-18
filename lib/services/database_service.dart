import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/models/app_models.dart';

class DatabaseService {
  static const String prayersBoxName = 'prayersBox';
  static const String defaultPrayersBoxName = 'defaultPrayersBox';
  static const String dhikrsBoxName = 'dhikrsBox';
  static const String notesBoxName = 'notesBox';
  static const String noteFoldersBoxName = 'noteFoldersBox';
  static const String settingsBoxName = 'settingsBox';

  static const String backupManifestVersion = '1.0.0';
  static const String backupJsonName = 'backup.json';
  static const String notesStorageDirectoryName = 'notes_storage';

  static Future<void> initDatabase() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CustomPrayerAdapter());
    Hive.registerAdapter(CustomDhikrAdapter());
    Hive.registerAdapter(NoteItemAdapter());
    Hive.registerAdapter(NoteFolderAdapter());

    await Hive.openBox<CustomPrayer>(prayersBoxName);
    await Hive.openBox<Map>(defaultPrayersBoxName);
    await Hive.openBox<CustomDhikr>(dhikrsBoxName);
    await Hive.openBox<NoteItem>(notesBoxName);
    await Hive.openBox<NoteFolder>(noteFoldersBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Future<Directory> appDataDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  static Future<File> createBackupArchive() async {
    final baseDir = await appDataDirectory();
    final tempDir = await getTemporaryDirectory();
    final exportedAt = DateTime.now();
    final backupPath = p.join(
      tempDir.path,
      'spiritual_tracker_backup_${exportedAt.millisecondsSinceEpoch}.zip',
    );

    final encoder = ZipFileEncoder();
    encoder.create(backupPath);

    final notesBox = Hive.box<NoteItem>(notesBoxName);
    final foldersBox = Hive.box<NoteFolder>(noteFoldersBoxName);
    final dhikrsBox = Hive.box<CustomDhikr>(dhikrsBoxName);
    final prayerBox = Hive.box<Map>(defaultPrayersBoxName);
    final settingsBox = Hive.box(settingsBoxName);

    final payload = {
      'manifest': {
        'version': backupManifestVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'notesCount': notesBox.length,
        'foldersCount': foldersBox.length,
        'dhikrCount': dhikrsBox.length,
        'prayerKeys': prayerBox.keys.map((key) => key.toString()).toList(),
      },
      'notes': notesBox.values
          .map(
            (note) => {
              'id': note.id,
              'title': note.title,
              'content': note.content,
              'type': note.type,
              'folderId': note.folderId,
              'fileSizeBytes': note.fileSizeBytes,
            },
          )
          .toList(),
      'folders': foldersBox.values
          .map(
            (folder) => {
              'id': folder.id,
              'name': folder.name,
            },
          )
          .toList(),
      'dhikrs': dhikrsBox.values
          .map(
            (dhikr) => {
              'id': dhikr.id,
              'text': dhikr.text,
              'count': dhikr.count,
            },
          )
          .toList(),
      'prayers': prayerBox.toMap().map(
            (key, value) => MapEntry(key.toString(), value),
          ),
      'settings': settingsBox.toMap().map(
            (key, value) => MapEntry(key.toString(), value),
          ),
    };

    final jsonFile = File(p.join(tempDir.path, backupJsonName));
    await jsonFile.writeAsString(jsonEncode(payload));
    encoder.addFile(jsonFile, backupJsonName);

    final notesDir = Directory(p.join(baseDir.path, notesStorageDirectoryName));
    if (await notesDir.exists()) {
      encoder.addDirectory(notesDir, includeDirName: true);
    }

    encoder.close();
    return File(backupPath);
  }

  static Future<void> restoreBackupArchive(File archiveFile) async {
    if (!await archiveFile.exists()) {
      throw Exception('Backup archive not found.');
    }

    final bytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final backupEntry = archive.findFile(backupJsonName);
    if (backupEntry == null) {
      throw Exception('Backup archive is missing backup.json.');
    }

    final payload = jsonDecode(utf8.decode(backupEntry.content as List<int>)) as Map<String, dynamic>;
    final notesBox = Hive.box<NoteItem>(notesBoxName);
    final foldersBox = Hive.box<NoteFolder>(noteFoldersBoxName);
    final dhikrsBox = Hive.box<CustomDhikr>(dhikrsBoxName);
    final prayerBox = Hive.box<Map>(defaultPrayersBoxName);
    final settingsBox = Hive.box(settingsBoxName);
    final appDir = await appDataDirectory();
    final notesStorageDir = Directory(p.join(appDir.path, notesStorageDirectoryName));

    if (await notesStorageDir.exists()) {
      await notesStorageDir.delete(recursive: true);
    }
    await notesStorageDir.create(recursive: true);

    await notesBox.clear();
    await foldersBox.clear();
    await dhikrsBox.clear();
    await prayerBox.clear();

    final previousBackupMetadata = {
      'backup_last_backup_at': settingsBox.get('backup_last_backup_at'),
      'backup_last_backup_name': settingsBox.get('backup_last_backup_name'),
      'backup_last_restore_at': settingsBox.get('backup_last_restore_at'),
    };
    await settingsBox.clear();

    for (final entry in archive) {
      if (!entry.isFile || entry.name == backupJsonName) continue;
      final outputPath = p.join(appDir.path, entry.name);
      final outputFile = File(outputPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(entry.content as List<int>);
    }

    final folders = (payload['folders'] as List<dynamic>? ?? <dynamic>[])
        .map((raw) => Map<String, dynamic>.from(raw as Map))
        .toList();
    for (final folder in folders) {
      final item = NoteFolder(
        id: folder['id'] as String? ?? '',
        name: folder['name'] as String? ?? 'Folder',
      );
      await foldersBox.put(item.id, item);
    }

    final notes = (payload['notes'] as List<dynamic>? ?? <dynamic>[])
        .map((raw) => Map<String, dynamic>.from(raw as Map))
        .toList();
    for (final note in notes) {
      final item = NoteItem(
        id: note['id'] as String? ?? '',
        title: note['title'] as String? ?? '',
        content: note['content'] as String? ?? '',
        type: note['type'] as String? ?? 'text',
        folderId: note['folderId'] as String? ?? '',
        fileSizeBytes: (note['fileSizeBytes'] as num?)?.toInt() ?? 0,
      );
      await notesBox.put(item.id, item);
    }

    final dhikrs = (payload['dhikrs'] as List<dynamic>? ?? <dynamic>[])
        .map((raw) => Map<String, dynamic>.from(raw as Map))
        .toList();
    for (final dhikr in dhikrs) {
      final item = CustomDhikr(
        id: dhikr['id'] as String? ?? '',
        text: dhikr['text'] as String? ?? '',
        count: (dhikr['count'] as num?)?.toInt() ?? 0,
      );
      await dhikrsBox.put(item.id, item);
    }

    final prayers = Map<String, dynamic>.from(payload['prayers'] as Map? ?? <String, dynamic>{});
    for (final entry in prayers.entries) {
      await prayerBox.put(entry.key, Map<String, dynamic>.from(entry.value as Map));
    }

    final restoredSettings = Map<String, dynamic>.from(payload['settings'] as Map? ?? <String, dynamic>{});
    for (final entry in restoredSettings.entries) {
      await settingsBox.put(entry.key, entry.value);
    }
    for (final entry in previousBackupMetadata.entries) {
      if (entry.value != null) {
        await settingsBox.put(entry.key, entry.value);
      }
    }
  }
}
