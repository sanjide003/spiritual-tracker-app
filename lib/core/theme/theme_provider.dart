// 📂 File: lib/core/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    // ജനറൽ ആയ 'settingsBox' ഉപയോഗിക്കുന്നു
    var box = Hive.box('settingsBox'); 
    _isDarkMode = box.get('isDarkMode', defaultValue: false) as bool;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    var box = Hive.box('settingsBox');
    box.put('isDarkMode', _isDarkMode); // ഇപ്പോൾ എറർ വരില്ല
    notifyListeners();
  }
}