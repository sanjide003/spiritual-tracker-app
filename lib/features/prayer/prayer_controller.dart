// 📂 File: lib/features/prayer/prayer_controller.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomPrayer {
  String id;
  String name;
  int rakah;
  bool isCompleted;

  CustomPrayer({required this.id, required this.name, required this.rakah, this.isCompleted = false});
}

class PrayerController extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();

  // ഡിഫോൾട്ട് 5 വഖ്ത്
  Map<String, String> defaultPrayers = {
    'Fajr': 'None',
    'Dhuhr': 'None',
    'Asr': 'None',
    'Maghrib': 'None',
    'Isha': 'None',
  };

  // സുന്നത്ത് നിസ്കാരങ്ങളുടെ ലിസ്റ്റ്
  List<CustomPrayer> sunnahPrayers = [];

  // തീയതി മാറ്റാൻ
  void changeDate(int days) {
    selectedDate = selectedDate.add(Duration(days: days));
    // (ഭാവിയിൽ ഇവിടെ ആ തീയതിയിലുള്ള ഡാറ്റ ഡാറ്റാബേസിൽ നിന്ന് എടുക്കാനുള്ള കോഡ് വരും)
    notifyListeners();
  }

  String get formattedDate => DateFormat('EEE, MMM d, yyyy').format(selectedDate);

  void updateDefaultPrayer(String name, String status) {
    defaultPrayers[name] = status;
    notifyListeners();
  }

  // സുന്നത്ത് നിസ്കാരം ആഡ് ചെയ്യാൻ
  void addSunnahPrayer(String name, int rakah) {
    sunnahPrayers.add(CustomPrayer(id: DateTime.now().toString(), name: name, rakah: rakah));
    notifyListeners();
  }

  // സുന്നത്ത് നിസ്കാരം എഡിറ്റ് ചെയ്യാൻ
  void editSunnahPrayer(String id, String newName, int newRakah) {
    var prayer = sunnahPrayers.firstWhere((p) => p.id == id);
    prayer.name = newName;
    prayer.rakah = newRakah;
    notifyListeners();
  }

  // സുന്നത്ത് നിസ്കാരം ഡിലീറ്റ് ചെയ്യാൻ
  void deleteSunnahPrayer(String id) {
    sunnahPrayers.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleSunnahStatus(String id) {
    var prayer = sunnahPrayers.firstWhere((p) => p.id == id);
    prayer.isCompleted = !prayer.isCompleted;
    notifyListeners();
  }
}