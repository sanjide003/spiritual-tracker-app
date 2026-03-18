import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/theme_provider.dart';
import 'backup_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<AppLanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backupController = Provider.of<BackupController>(context);

    return Scaffold(
      appBar: AppBar(title: Text(langProvider.translate('tab_settings')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BackupCard(controller: backupController),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: langProvider.currentLanguage,
                  onChanged: (val) => langProvider.changeLanguage(val!),
                ),
                RadioListTile<String>(
                  title: const Text('മലയാളം'),
                  value: 'ml',
                  groupValue: langProvider.currentLanguage,
                  onChanged: (val) => langProvider.changeLanguage(val!),
                ),
                RadioListTile<String>(
                  title: const Text('العربية'),
                  value: 'ar',
                  groupValue: langProvider.currentLanguage,
                  onChanged: (val) => langProvider.changeLanguage(val!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({required this.controller});

  final BackupController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Storage + Google Drive Backup',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'All data stays on the phone by default. Sign in only when you want to create a Google Drive backup.',
            ),
            const SizedBox(height: 16),
            if (controller.currentUser == null)
              FilledButton.icon(
                onPressed: controller.signIn,
                icon: const Icon(Icons.login),
                label: const Text('Sign in to Google Drive'),
              )
            else
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.cloud_done)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.currentUser!.displayName ?? 'Google Account'),
                        Text(controller.currentUser!.email),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: controller.signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: controller.isUploading ? controller.progress : 0),
            const SizedBox(height: 8),
            Text(controller.statusMessage),
            const SizedBox(height: 8),
            Text(
              '${(controller.progress * 100).toStringAsFixed(1)}% • ${controller.uploadedMb.toStringAsFixed(2)} MB / ${controller.totalMb.toStringAsFixed(2)} MB',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: controller.isUploading ? null : controller.uploadBackup,
                  icon: const Icon(Icons.upload),
                  label: const Text('Backup to Drive'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isUploading && !controller.isPaused ? controller.pauseUpload : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isUploading && controller.isPaused ? controller.resumeUpload : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isUploading ? controller.cancelUpload : null,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
