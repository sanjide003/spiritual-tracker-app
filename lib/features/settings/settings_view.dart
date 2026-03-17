// 📂 File: lib/features/settings/settings_view.dart
// അഞ്ചാമത്തെ ടാബ് (സെറ്റിംഗ്സ്)

import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'App Settings, Backup & Language go here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}