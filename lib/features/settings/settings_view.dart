// 📂 File: lib/features/settings/settings_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<AppLanguageProvider>(context);
    final currentLang = langProvider.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('tab_settings')),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Language / ഭാഷ / لغة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: currentLang,
            onChanged: (val) => langProvider.changeLanguage(val!),
          ),
          RadioListTile<String>(
            title: const Text('മലയാളം'),
            value: 'ml',
            groupValue: currentLang,
            onChanged: (val) => langProvider.changeLanguage(val!),
          ),
          RadioListTile<String>(
            title: const Text('العربية'),
            value: 'ar',
            groupValue: currentLang,
            onChanged: (val) => langProvider.changeLanguage(val!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Backup Data (Coming Soon)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Firebase backup will be implemented in the next phase')),
              );
            },
          ),
        ],
      ),
    );
  }
}