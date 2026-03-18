import 'dart:convert';
import 'dart:io';

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
    final backupPath = p.join(
      tempDir.path,
      'spiritual_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
    );

    final encoder = ZipFileEncoder();
    encoder.create(backupPath);

    final notesBox = Hive.box<NoteItem>(notesBoxName);
    final foldersBox = Hive.box<NoteFolder>(noteFoldersBoxName);
    final dhikrsBox = Hive.box<CustomDhikr>(dhikrsBoxName);
    final prayerBox = Hive.box<Map>(defaultPrayersBoxName);
    final settingsBox = Hive.box(settingsBoxName);

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
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

    final jsonFile = File(p.join(tempDir.path, 'backup.json'));
    await jsonFile.writeAsString(jsonEncode(payload));
    encoder.addFile(jsonFile, 'backup.json');

    final notesDir = Directory(p.join(baseDir.path, 'notes_storage'));
    if (await notesDir.exists()) {
      encoder.addDirectory(notesDir, includeDirName: true);
    }

    encoder.close();
    return File(backupPath);
  }
}
