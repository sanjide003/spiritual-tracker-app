import 'dart:async';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../services/database_service.dart';

class BackupController extends ChangeNotifier {
  BackupController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? currentUser;
  bool isUploading = false;
  bool isPaused = false;
  bool isCancelled = false;
  double progress = 0;
  int uploadedBytes = 0;
  int totalBytes = 0;
  String statusMessage = 'Local-only mode active';
  String? lastBackupFileName;

  StreamSubscription<List<int>>? _streamSubscription;
  StreamController<List<int>>? _streamController;
  AuthClient? _client;

  double get uploadedMb => uploadedBytes / (1024 * 1024);
  double get totalMb => totalBytes / (1024 * 1024);

  Future<void> signIn() async {
    currentUser = await _googleSignIn.signIn();
    statusMessage = currentUser == null
        ? 'Google sign-in cancelled'
        : 'Connected to ${currentUser!.email}';
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    currentUser = null;
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
    uploadedBytes = 0;
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
      final stream = _createTrackedStream(archive);
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
        statusMessage = 'Backup completed successfully';
      }
    } catch (error) {
      statusMessage = 'Backup failed: $error';
    } finally {
      await _streamSubscription?.cancel();
      await _streamController?.close();
      _client?.close();
      _streamSubscription = null;
      _streamController = null;
      _client = null;
      isUploading = false;
      isPaused = false;
      notifyListeners();
    }
  }

  Stream<List<int>> _createTrackedStream(File file) {
    final controller = StreamController<List<int>>();
    _streamController = controller;
    _streamSubscription = file.openRead().listen(
      (chunk) {
        if (isCancelled) {
          controller.close();
          return;
        }
        uploadedBytes += chunk.length;
        progress = totalBytes == 0 ? 0 : uploadedBytes / totalBytes;
        statusMessage = 'Uploading ${uploadedMb.toStringAsFixed(2)} MB of ${totalMb.toStringAsFixed(2)} MB';
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
    if (!isUploading) return;
    isCancelled = true;
    await _streamSubscription?.cancel();
    await _streamController?.close();
    statusMessage = 'Cancelling backup...';
    notifyListeners();
  }
}
