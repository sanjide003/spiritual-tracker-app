// 📂 File: lib/features/prayer/prayer_controller.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/app_models.dart';

class PrayerController extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  final Box<Map> _defaultBox = Hive.box<Map>('defaultPrayersBox');
  final Box<CustomPrayer> _sunnahBox = Hive.box<CustomPrayer>('prayersBox');

  Map<String, String> defaultPrayers = {};
  List<CustomPrayer> sunnahPrayers = [];

  PrayerController() {
    _loadDataForDate();
  }

  String get dateKey => DateFormat('yyyy-MM-dd').format(selectedDate);
  String get formattedDate => DateFormat('EEE, MMM d, yyyy').format(selectedDate);

  void _loadDataForDate() {
    // ലോക്കൽ ഡാറ്റാബേസിൽ നിന്ന് ഇന്നത്തെ ഡാറ്റ എടുക്കുന്നു
    var savedPrayers = _defaultBox.get(dateKey);
    if (savedPrayers != null) {
      defaultPrayers = Map<String, String>.from(savedPrayers);
    } else {
      defaultPrayers = {'Fajr': 'None', 'Dhuhr': 'None', 'Asr': 'None', 'Maghrib': 'None', 'Isha': 'None'};
    }
    
    sunnahPrayers = _sunnahBox.values.where((p) => p.date == dateKey).toList();
    notifyListeners();
  }

  void changeDate(int days) {
    selectedDate = selectedDate.add(Duration(days: days));
    _loadDataForDate(); // പുതിയ തീയതിയിലെ ഡാറ്റ ലോഡ് ചെയ്യുന്നു
  }

  void updateDefaultPrayer(String name, String status) {
    defaultPrayers[name] = status;
    _defaultBox.put(dateKey, defaultPrayers); // ഡാറ്റാബേസിൽ സേവ് ചെയ്യുന്നു
    notifyListeners();
  }

  void addSunnahPrayer(String name, int rakah) {
    final newPrayer = CustomPrayer(
      id: DateTime.now().toString(), name: name, rakah: rakah, date: dateKey
    );
    _sunnahBox.put(newPrayer.id, newPrayer);
    _loadDataForDate();
  }

  void editSunnahPrayer(String id, String newName, int newRakah) {
    var prayer = _sunnahBox.get(id);
    if (prayer != null) {
      prayer.name = newName;
      prayer.rakah = newRakah;
      prayer.save(); // Hive Auto Save
      _loadDataForDate();
    }
  }

  void deleteSunnahPrayer(String id) {
    _sunnahBox.delete(id);
    _loadDataForDate();
  }

  void toggleSunnahStatus(String id) {
    var prayer = _sunnahBox.get(id);
    if (prayer != null) {
      prayer.isCompleted = !prayer.isCompleted;
      prayer.save();
      _loadDataForDate();
    }
  }

  // ഡാഷ്‌ബോർഡിന് വേണ്ടി ആകെ ബാക്കിയുള്ള ഖളാഅ് കണ്ടുപിടിക്കാൻ
  int getTotalPendingQadha() {
    int total = 0;
    for (var val in _defaultBox.values) {
      if (val is Map) {
        val.forEach((key, status) {
          if (status == 'Missed') total++;
        });
      }
    }
    return total;
  }
}