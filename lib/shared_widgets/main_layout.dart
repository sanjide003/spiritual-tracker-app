// 📂 File: lib/shared_widgets/main_layout.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_localizations.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/prayer/prayer_view.dart';
import '../features/dhikr/dhikr_list_view.dart';
import '../features/notes/notes_list_view.dart';
import '../features/settings/settings_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardView(), // Habits മാറി Dashboard ആയി
    PrayerView(),
    DhikrListView(),
    NotesListView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: lang.translate('tab_dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.mosque_outlined),
            selectedIcon: const Icon(Icons.mosque),
            label: lang.translate('tab_prayer'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.fingerprint),
            label: lang.translate('tab_dhikr'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.edit_note_outlined),
            selectedIcon: const Icon(Icons.edit_note),
            label: lang.translate('tab_notes'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: lang.translate('tab_settings'),
          ),
        ],
      ),
    );
  }
}