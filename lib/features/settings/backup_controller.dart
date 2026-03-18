import 'dart:async';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../services/database_service.dart';

class DriveBackupItem {
  const DriveBackupItem({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.modifiedTime,
  });

  final String id;
  final String name;
  final int sizeBytes;
  final DateTime? modifiedTime;

  double get sizeMb => sizeBytes / (1024 * 1024);
}

class BackupController extends ChangeNotifier {
  BackupController() {
    _loadSavedMetadata();
  }

  static const String _lastBackupAtKey = 'backup_last_backup_at';
  static const String _lastBackupNameKey = 'backup_last_backup_name';
  static const String _lastRestoreAtKey = 'backup_last_restore_at';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  final Box<dynamic> _settingsBox = Hive.box(DatabaseService.settingsBoxName);

  GoogleSignInAccount? currentUser;
  bool isUploading = false;
  bool isRestoring = false;
  bool isLoadingBackups = false;
  bool isPaused = false;
  bool isCancelled = false;
  double progress = 0;
  int transferredBytes = 0;
  int totalBytes = 0;
  String statusMessage = 'Local-only mode active';
  String? lastBackupFileName;
  DateTime? lastBackupAt;
  DateTime? lastRestoreAt;
  List<DriveBackupItem> availableBackups = const [];

  StreamSubscription<List<int>>? _streamSubscription;
  StreamController<List<int>>? _streamController;
  AuthClient? _client;

  double get transferredMb => transferredBytes / (1024 * 1024);
  double get totalMb => totalBytes / (1024 * 1024);
  bool get isBusy => isUploading || isRestoring || isLoadingBackups;
  DriveBackupItem? get latestBackup => availableBackups.isEmpty ? null : availableBackups.first;

  Future<void> signIn() async {
    currentUser = await _googleSignIn.signIn();
    statusMessage = currentUser == null
        ? 'Google sign-in cancelled'
        : 'Connected to ${currentUser!.email}';
    notifyListeners();
    if (currentUser != null) {
      await loadAvailableBackups();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    currentUser = null;
    availableBackups = const [];
    statusMessage = 'Signed out from Google Drive';
    notifyListeners();
  }

  Future<void> uploadBackup() async {
    if (currentUser == null) {
      await signIn();
      if (currentUser == null) return;
    }

    isUploading = true;
    isPaused = false;
    isCancelled = false;
    progress = 0;
    transferredBytes = 0;
    totalBytes = 0;
    statusMessage = 'Preparing backup archive...';
    notifyListeners();

    File? archive;

    try {
      archive = await DatabaseService.createBackupArchive();
      totalBytes = await archive.length();
      lastBackupFileName = archive.uri.pathSegments.last;
      statusMessage = 'Signing in to Google Drive...';
      notifyListeners();

      _client = await _googleSignIn.authenticatedClient();
      if (_client == null) {
        throw Exception('Unable to authenticate with Google Drive.');
      }

      final driveApi = drive.DriveApi(_client!);
      final stream = _createTrackedUploadStream(archive);
      final media = drive.Media(stream, totalBytes);

      statusMessage = 'Uploading backup to Google Drive...';
      notifyListeners();

      await driveApi.files.create(
        drive.File()
          ..name = lastBackupFileName
          ..parents = ['appDataFolder'],
        uploadMedia: media,
      );

      if (isCancelled) {
        statusMessage = 'Backup cancelled';
      } else {
        progress = 1;
        lastBackupAt = DateTime.now();
        await _persistMetadata();
        statusMessage = 'Backup completed successfully';
        await loadAvailableBackups();
      }
    } catch (error) {
      statusMessage = 'Backup failed: $error';
    } finally {
      await _resetTransferResources();
      isUploading = false;
      isPaused = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableBackups() async {
    if (currentUser == null) return;
    isLoadingBackups = true;
    statusMessage = 'Loading backups from Google Drive...';
    notifyListeners();

    try {
      _client ??= await _googleSignIn.authenticatedClient();
      if (_client == null) {
        throw Exception('Unable to authenticate with Google Drive.');
      }

      final driveApi = drive.DriveApi(_client!);
      final response = await driveApi.files.list(
        q: "'appDataFolder' in parents and trashed = false",
        spaces: 'appDataFolder',
        orderBy: 'modifiedTime desc',
        $fields: 'files(id,name,size,modifiedTime)',
      );

      availableBackups = (response.files ?? <drive.File>[])
          .where((file) => file.id != null && file.name != null)
          .map(
            (file) => DriveBackupItem(
              id: file.id!,
              name: file.name!,
              sizeBytes: file.size?.toInt() ?? 0,
              modifiedTime: file.modifiedTime,
            ),
          )
          .toList();

      statusMessage = availableBackups.isEmpty
          ? 'No Drive backups found yet'
          : 'Found ${availableBackups.length} backup file(s)';
    } catch (error) {
      statusMessage = 'Could not load backup list: $error';
    } finally {
      isLoadingBackups = false;
      _client?.close();
      _client = null;
      notifyListeners();
    }
  }

  Future<void> restoreBackup(DriveBackupItem backup) async {
    if (currentUser == null) {
      await signIn();
      if (currentUser == null) return;
    }

    isRestoring = true;
    isCancelled = false;
    progress = 0;
    transferredBytes = 0;
    totalBytes = backup.sizeBytes;
    statusMessage = 'Downloading ${backup.name}...';
    notifyListeners();

    File? downloadFile;

    try {
      _client = await _googleSignIn.authenticatedClient();
      if (_client == null) {
        throw Exception('Unable to authenticate with Google Drive.');
      }

      final driveApi = drive.DriveApi(_client!);
      final media = await driveApi.files.get(
        backup.id,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final tempDir = await getTemporaryDirectory();
      downloadFile = File(p.join(tempDir.path, backup.name));
      final sink = downloadFile.openWrite();

      await for (final chunk in media.stream) {
        if (isCancelled) {
          await sink.close();
          if (await downloadFile.exists()) {
            await downloadFile.delete();
          }
          statusMessage = 'Restore cancelled';
          return;
        }
        sink.add(chunk);
        transferredBytes += chunk.length;
        progress = totalBytes == 0 ? 0 : transferredBytes / totalBytes;
        statusMessage =
            'Downloading ${transferredMb.toStringAsFixed(2)} MB of ${totalMb.toStringAsFixed(2)} MB';
        notifyListeners();
      }
      await sink.close();

      statusMessage = 'Applying backup to local storage...';
      notifyListeners();

      await DatabaseService.restoreBackupArchive(downloadFile);
      progress = 1;
      lastRestoreAt = DateTime.now();
      await _persistMetadata();
      statusMessage = 'Restore completed successfully';
    } catch (error) {
      statusMessage = 'Restore failed: $error';
    } finally {
      _client?.close();
      _client = null;
      isRestoring = false;
      isCancelled = false;
      notifyListeners();
    }
  }

  Stream<List<int>> _createTrackedUploadStream(File file) {
    final controller = StreamController<List<int>>();
    _streamController = controller;
    _streamSubscription = file.openRead().listen(
      (chunk) {
        if (isCancelled) {
          controller.close();
          return;
        }
        transferredBytes += chunk.length;
        progress = totalBytes == 0 ? 0 : transferredBytes / totalBytes;
        statusMessage =
            'Uploading ${transferredMb.toStringAsFixed(2)} MB of ${totalMb.toStringAsFixed(2)} MB';
        notifyListeners();
        controller.add(chunk);
      },
      onDone: () async {
        await controller.close();
      },
      onError: controller.addError,
      cancelOnError: true,
    );
    return controller.stream;
  }

  void pauseUpload() {
    if (!isUploading || isPaused) return;
    _streamSubscription?.pause();
    isPaused = true;
    statusMessage = 'Backup paused';
    notifyListeners();
  }

  void resumeUpload() {
    if (!isUploading || !isPaused) return;
    _streamSubscription?.resume();
    isPaused = false;
    statusMessage = 'Resuming backup upload...';
    notifyListeners();
  }

  Future<void> cancelUpload() async {
    if (!isUploading && !isRestoring) return;
    isCancelled = true;
    await _streamSubscription?.cancel();
    await _streamController?.close();
    statusMessage = isRestoring ? 'Cancelling restore...' : 'Cancelling backup...';
    notifyListeners();
  }

  void _loadSavedMetadata() {
    final savedBackupAt = _settingsBox.get(_lastBackupAtKey) as String?;
    final savedRestoreAt = _settingsBox.get(_lastRestoreAtKey) as String?;
    lastBackupFileName = _settingsBox.get(_lastBackupNameKey) as String?;
    lastBackupAt = savedBackupAt == null ? null : DateTime.tryParse(savedBackupAt);
    lastRestoreAt = savedRestoreAt == null ? null : DateTime.tryParse(savedRestoreAt);
  }

  Future<void> _persistMetadata() async {
    if (lastBackupAt != null) {
      await _settingsBox.put(_lastBackupAtKey, lastBackupAt!.toIso8601String());
    }
    if (lastBackupFileName != null) {
      await _settingsBox.put(_lastBackupNameKey, lastBackupFileName);
    }
    if (lastRestoreAt != null) {
      await _settingsBox.put(_lastRestoreAtKey, lastRestoreAt!.toIso8601String());
    }
  }

  Future<void> _resetTransferResources() async {
    await _streamSubscription?.cancel();
    await _streamController?.close();
    _client?.close();
    _streamSubscription = null;
    _streamController = null;
    _client = null;
  }
}
