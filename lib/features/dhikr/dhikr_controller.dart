// 📂 File: lib/features/dhikr/dhikr_controller.dart

import 'package:flutter/material.dart';

class DhikrItem {
  String title;
  int count;
  int target;

  DhikrItem({required this.title, this.count = 0, required this.target});
}

class DhikrController extends ChangeNotifier {
  // ആപ്പിലെ ഡിഫോൾട്ട് ദിക്റുകൾ
  final List<DhikrItem> dhikrs = [
    DhikrItem(title: 'Subhanallah', target: 33),
    DhikrItem(title: 'Alhamdulillah', target: 33),
    DhikrItem(title: 'Allahu Akbar', target: 34),
  ];

  // ദിക്റ് എണ്ണം കൂട്ടാൻ
  void incrementCount(int index) {
    if (dhikrs[index].count < dhikrs[index].target) {
      dhikrs[index].count++;
      notifyListeners();
    }
  }

  // കൗണ്ട് റീസെറ്റ് ചെയ്യാൻ
  void resetCount(int index) {
    dhikrs[index].count = 0;
    notifyListeners();
  }

  // പുതിയ ദിക്റ് ആഡ് ചെയ്യാൻ
  void addCustomDhikr(String title, int target) {
    dhikrs.add(DhikrItem(title: title, target: target));
    notifyListeners();
  }

  // ദിക്റ് ഡിലീറ്റ് ചെയ്യാൻ
  void deleteDhikr(int index) {
    dhikrs.removeAt(index);
    notifyListeners();
  }
}