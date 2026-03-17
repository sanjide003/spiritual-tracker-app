// 📂 File: lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    // ആപ്പ് തുടങ്ങുമ്പോൾ സേവ് ചെയ്ത തീം എടുക്കാൻ
    var box = Hive.box<Map>('defaultPrayersBox'); // Settings സേവ് ചെയ്യാനും ഈ ബോക്സ് ഉപയോഗിക്കാം
    _isDarkMode = box.get('isDarkMode', defaultValue: false) as bool;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    var box = Hive.box<Map>('defaultPrayersBox');
    box.put('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}