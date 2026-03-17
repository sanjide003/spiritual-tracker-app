// 📂 File: lib/features/prayer/prayer_controller.dart
// നിസ്കാരങ്ങളുടെ ഡാറ്റയും ലോജിക്കും കൈകാര്യം ചെയ്യുന്ന ഫയൽ

import 'package:flutter/material.dart';

class PrayerController extends ChangeNotifier {
  // ഇന്നത്തെ നിസ്കാരങ്ങളുടെ സ്റ്റാറ്റസ് (None, Ada, Qadha, Missed)
  Map<String, String> todayPrayers = {
    'Fajr': 'None',
    'Dhuhr': 'None',
    'Asr': 'None',
    'Maghrib': 'None',
    'Isha': 'None',
  };

  // ബാക്കിയുള്ള ഖളാഅ് നിസ്കാരങ്ങളുടെ എണ്ണം
  Map<String, int> qadhaCount = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  // ഇന്നത്തെ നിസ്കാരത്തിന്റെ സ്റ്റാറ്റസ് മാറ്റാൻ (Ada/Qadha/Missed)
  void updateTodayPrayer(String prayerName, String status) {
    // മുൻപ് 'Missed' ആയിരുന്ന ഒരെണ്ണം ഇപ്പോൾ 'Ada' ആക്കിയാൽ,
    // ഖളാഅ് കൗണ്ടറിൽ നിന്ന് അത് കുറയ്ക്കണം (ഓട്ടോമാറ്റിക് അഡ്ജസ്റ്റ്മെന്റ്)
    if (todayPrayers[prayerName] == 'Missed' && status != 'Missed') {
       if(qadhaCount[prayerName]! > 0) qadhaCount[prayerName] = qadhaCount[prayerName]! - 1;
    } 
    // പുതിയതായി 'Missed' എന്ന് മാർക്ക് ചെയ്താൽ, ഖളാഅ് കൗണ്ടർ ഒന്ന് കൂട്ടണം
    else if (status == 'Missed' && todayPrayers[prayerName] != 'Missed') {
       qadhaCount[prayerName] = qadhaCount[prayerName]! + 1;
    }

    todayPrayers[prayerName] = status;
    notifyListeners();
  }

  // പഴയ ഖളാഅ് നിസ്കാരം വീട്ടുമ്പോൾ എണ്ണം കുറയ്ക്കാൻ
  void decrementQadha(String prayerName) {
    if (qadhaCount[prayerName]! > 0) {
      qadhaCount[prayerName] = qadhaCount[prayerName]! - 1;
      notifyListeners();
    }
  }

  // മാനുവൽ ആയി ഖളാഅ് എണ്ണം കൂട്ടാൻ (സെറ്റിംഗ്സിന് വേണ്ടി)
  void incrementQadha(String prayerName) {
    qadhaCount[prayerName] = qadhaCount[prayerName]! + 1;
    notifyListeners();
  }
}