// 📂 File: lib/services/database_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/app_models.dart';

class DatabaseService {
  // ബോക്സുകളുടെ പേരുകൾ
  static const String prayersBoxName = 'prayersBox';
  static const String defaultPrayersBoxName = 'defaultPrayersBox';
  static const String dhikrsBoxName = 'dhikrsBox';
  static const String notesBoxName = 'notesBox';
  static const String settingsBoxName = 'settingsBox'; // സെറ്റിംഗ്സിനായി പുതിയ ബോക്സ്

  static Future<void> initDatabase() async {
    await Hive.initFlutter();

    // മോഡലുകൾ പരിചയപ്പെടുത്തുന്നു
    Hive.registerAdapter(CustomPrayerAdapter());
    Hive.registerAdapter(CustomDhikrAdapter());
    Hive.registerAdapter(NoteItemAdapter());

    // ബോക്സുകൾ ഓപ്പൺ ചെയ്യുന്നു
    await Hive.openBox<CustomPrayer>(prayersBoxName);
    await Hive.openBox<Map>(defaultPrayersBoxName); 
    await Hive.openBox<CustomDhikr>(dhikrsBoxName);
    await Hive.openBox<NoteItem>(notesBoxName);
    
    // ഡാർക്ക് മോഡും ഭാഷകളും സേവ് ചെയ്യാൻ ഒരു ജനറൽ ബോക്സ് ഓപ്പൺ ചെയ്യുന്നു
    await Hive.openBox(settingsBoxName); 
  }
}