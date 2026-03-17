// 📂 File: lib/shared_widgets/main_layout.dart
// പഴയ main_layout.dart പൂർണ്ണമായും മാറ്റി ഇത് നൽകുക

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_localizations.dart';
import '../features/prayer/prayer_view.dart';
import '../features/dhikr/dhikr_list_view.dart';
import '../features/habits/habit_list_view.dart';
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
    PrayerView(),
    DhikrListView(),
    HabitListView(),
    NotesListView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    // ഭാഷകൾ എടുക്കാൻ പ്രൊവൈഡർ വിളിക്കുന്നു
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
            icon: const Icon(Icons.mosque_outlined),
            selectedIcon: const Icon(Icons.mosque),
            label: lang.translate('tab_prayer'), // ഭാഷ മാറുമ്പോൾ ഈ പേരും മാറും
          ),
          NavigationDestination(
            icon: const Icon(Icons.fingerprint),
            label: lang.translate('tab_dhikr'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: const Icon(Icons.check_circle),
            label: lang.translate('tab_habits'),
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