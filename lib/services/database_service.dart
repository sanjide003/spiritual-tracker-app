// 📂 File: lib/services/database_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/app_models.dart';

class DatabaseService {
  // ബോക്സുകളുടെ പേരുകൾ (Table Names)
  static const String prayersBoxName = 'prayersBox';
  static const String defaultPrayersBoxName = 'defaultPrayersBox';
  static const String dhikrsBoxName = 'dhikrsBox';
  static const String notesBoxName = 'notesBox';

  // ഡാറ്റാബേസ് ഇനിഷ്യലൈസ് ചെയ്യാനുള്ള ഫംഗ്ഷൻ (main.dart ൽ വിളിക്കാൻ)
  static Future<void> initDatabase() async {
    await Hive.initFlutter();

    // മോഡലുകൾ ഡാറ്റാബേസിനെ പരിചയപ്പെടുത്തുന്നു
    Hive.registerAdapter(CustomPrayerAdapter());
    Hive.registerAdapter(CustomDhikrAdapter());
    Hive.registerAdapter(NoteItemAdapter());

    // ബോക്സുകൾ ഓപ്പൺ ചെയ്യുന്നു
    await Hive.openBox<CustomPrayer>(prayersBoxName);
    await Hive.openBox<Map>(defaultPrayersBoxName); // 5 വഖ്ത് സേവ് ചെയ്യാൻ
    await Hive.openBox<CustomDhikr>(dhikrsBoxName);
    await Hive.openBox<NoteItem>(notesBoxName);
  }
}