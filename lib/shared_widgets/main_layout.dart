// 📂 File: lib/shared_widgets/main_layout.dart
// താഴെ കാണുന്ന 5 ടാബുകൾ ഉള്ള നാവിഗേഷൻ ബാർ ഇതാണ്.

import 'package:flutter/material.dart';

// മറ്റ് സ്ക്രീനുകൾ ഇമ്പോർട്ട് ചെയ്യുന്നു
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

  // ഓരോ ടാബിലും കാണിക്കേണ്ട സ്ക്രീനുകളുടെ ലിസ്റ്റ്
  final List<Widget> _screens = const [
    PrayerView(),
    DhikrListView(),
    HabitListView(),
    NotesListView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ഒരു ടാബിൽ നിന്ന് മറ്റൊന്നിലേക്ക് പോകുമ്പോൾ ഡാറ്റ മാഞ്ഞുപോകാതിരിക്കാൻ IndexedStack ഉപയോഗിക്കുന്നു
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'Prayer',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint),
            label: 'Dhikr',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}