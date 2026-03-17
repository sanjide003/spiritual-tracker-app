// 📂 File: lib/core/localization/app_localizations.dart

import 'package:flutter/material.dart';

class AppLanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  String translate(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Spiritual Tracker',
      'tab_dashboard': 'Dashboard',
      'tab_prayer': 'Prayer',
      'tab_dhikr': 'Dhikr',
      'tab_notes': 'Notes',
      'tab_settings': 'Settings',
    },
    'ml': {
      'app_title': 'സ്പിരിച്വൽ ട്രാക്കർ',
      'tab_dashboard': 'ഡാഷ്‌ബോർഡ്',
      'tab_prayer': 'നിസ്കാരം',
      'tab_dhikr': 'ദിക്റ്',
      'tab_notes': 'നോട്ട്സ്',
      'tab_settings': 'സെറ്റിംഗ്സ്',
    },
    'ar': {
      'app_title': 'المتعقب الروحي',
      'tab_dashboard': 'لوحة القيادة',
      'tab_prayer': 'صلاة',
      'tab_dhikr': 'ذكر',
      'tab_notes': 'ملاحظات',
      'tab_settings': 'إعدادات',
    }
  };
}