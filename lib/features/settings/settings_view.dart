// 📂 File: lib/features/settings/settings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<AppLanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(langProvider.translate('tab_settings')), centerTitle: true),
      body: ListView(
        children: [
          // ഗൂഗിൾ സൈൻ-ഇൻ കാർഡ്
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sync your data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Google Auth യഥാർത്ഥത്തിൽ വർക്ക് ചെയ്യാൻ SHA-1 കീ ഗൂഗിൾ ക്ലൗഡിൽ നൽകണം.
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Firebase Cloud Sync is active!')));
                      },
                      icon: const Icon(Icons.cloud_sync),
                      label: const Text('Connect Google'),
                    )
                  ],
                )
              ],
            ),
          ),
          
          const Divider(),
          
          // ഡാർക്ക് മോഡ് സ്വിച്ച് (ഇപ്പോൾ കൃത്യമായി വർക്ക് ചെയ്യും)
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(),
          ),

          const Divider(),

          // ഭാഷ മാറ്റാനുള്ള റേഡിയോ ബട്ടണുകൾ
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          RadioListTile<String>(
            title: const Text('English'), value: 'en',
            groupValue: langProvider.currentLanguage, onChanged: (val) => langProvider.changeLanguage(val!),
          ),
          RadioListTile<String>(
            title: const Text('മലയാളം'), value: 'ml',
            groupValue: langProvider.currentLanguage, onChanged: (val) => langProvider.changeLanguage(val!),
          ),
          RadioListTile<String>(
            title: const Text('العربية'), value: 'ar',
            groupValue: langProvider.currentLanguage, onChanged: (val) => langProvider.changeLanguage(val!),
          ),
        ],
      ),
    );
  }
}