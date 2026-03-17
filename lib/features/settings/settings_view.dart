// 📂 File: lib/features/settings/settings_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('tab_settings')),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // പ്രൊഫൈൽ കാർഡ് (Google Sign In ന് ശേഷം കാണിക്കുന്നത്)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 40), // ലോഗിൻ ചെയ്താൽ ഫോട്ടോ വരും
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Not Signed In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Google Auth Logic ഇവിടെ വരും
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Sign-in initializing...')));
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                    )
                  ],
                )
              ],
            ),
          ),
          
          const Divider(),
          
          // തീം മാറ്റാൻ
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: false, // തീം പ്രൊവൈഡർ ആഡ് ചെയ്യുമ്പോൾ ഇത് ശരിയാകും
            onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme switching will be added soon')));
            },
          ),

          const Divider(),

          // ഭാഷ മാറ്റാൻ
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }
}