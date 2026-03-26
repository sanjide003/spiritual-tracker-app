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
              title: Text(langProvider.translate('settings_dark_mode')),
              secondary: const Icon(Icons.dark_mode),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      langProvider.translate('settings_language'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.translate('settings_backup_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(lang.translate('settings_backup_subtitle')),
            const SizedBox(height: 16),
            if (controller.currentUser == null)
              FilledButton.icon(
                onPressed: controller.signIn,
                icon: const Icon(Icons.login),
                label: Text(lang.translate('settings_sign_in_drive')),
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
                        Text(controller.currentUser!.displayName ?? lang.translate('settings_google_account')),
                        Text(controller.currentUser!.email),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: controller.signOut,
                    child: Text(lang.translate('settings_sign_out')),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: controller.isBusy ? controller.progress : 0),
            const SizedBox(height: 8),
            Text(lang.translateWithArgs(controller.statusKey, controller.statusArgs)),
            const SizedBox(height: 8),
            Text(
              '${(controller.progress * 100).toStringAsFixed(1)}% • ${controller.transferredMb.toStringAsFixed(2)} MB / ${controller.totalMb.toStringAsFixed(2)} MB',
            ),
            const SizedBox(height: 12),
            if (controller.lastBackupAt != null)
              Text(lang.translateWithArgs('settings_last_backup', {'value': _formatDateTime(controller.lastBackupAt!)})),
            if (controller.lastBackupFileName != null)
              Text(lang.translateWithArgs('settings_last_backup_file', {'value': controller.lastBackupFileName!})),
            if (controller.lastRestoreAt != null)
              Text(lang.translateWithArgs('settings_last_restore', {'value': _formatDateTime(controller.lastRestoreAt!)})),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: controller.isBusy ? null : controller.uploadBackup,
                  icon: const Icon(Icons.upload),
                  label: Text(lang.translate('settings_backup_to_drive')),
                ),
                FilledButton.icon(
                  onPressed: controller.currentUser == null || controller.isBusy ? null : controller.loadAvailableBackups,
                  icon: const Icon(Icons.refresh),
                  label: Text(lang.translate('settings_refresh_backups')),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isUploading && !controller.isPaused ? controller.pauseUpload : null,
                  icon: const Icon(Icons.pause),
                  label: Text(lang.translate('settings_pause')),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isUploading && controller.isPaused ? controller.resumeUpload : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(lang.translate('settings_resume')),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isBusy ? controller.cancelUpload : null,
                  icon: const Icon(Icons.close),
                  label: Text(lang.translate('common_cancel')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  lang.translate('settings_available_backups'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (controller.isLoadingBackups)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (controller.availableBackups.isEmpty)
              Text(lang.translate('settings_no_backups'))
            else
              Column(
                children: controller.availableBackups
                    .map(
                      (backup) => Card(
                        margin: const EdgeInsets.only(top: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(Icons.backup_outlined),
                          ),
                          title: Text(backup.name),
                          subtitle: Text(
                            '${backup.sizeMb.toStringAsFixed(2)} MB • ${backup.modifiedTime == null ? lang.translate('settings_unknown_date') : _formatDateTime(backup.modifiedTime!)}',
                          ),
                          trailing: TextButton.icon(
                            onPressed: controller.isBusy ? null : () => controller.restoreBackup(backup),
                            icon: const Icon(Icons.restore),
                            label: Text(lang.translate('settings_restore')),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}
