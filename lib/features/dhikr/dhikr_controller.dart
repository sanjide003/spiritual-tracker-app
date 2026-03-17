// 📂 File: lib/features/dhikr/dhikr_controller.dart

import 'package:flutter/material.dart';

class CustomDhikr {
  String id;
  String text;
  int count;

  CustomDhikr({required this.id, required this.text, this.count = 0});
}

class DhikrController extends ChangeNotifier {
  List<CustomDhikr> dhikrs = []; // ഡിഫോൾട്ട് ഒന്നുമില്ല
  String? selectedDhikrId;

  CustomDhikr? get selectedDhikr {
    if (selectedDhikrId == null || dhikrs.isEmpty) return null;
    try {
      return dhikrs.firstWhere((d) => d.id == selectedDhikrId);
    } catch(e) {
      return null;
    }
  }

  void selectDhikr(String id) {
    selectedDhikrId = id;
    notifyListeners();
  }

  void increment() {
    if (selectedDhikr != null) {
      selectedDhikr!.count++;
      notifyListeners();
    }
  }

  void addDhikr(String text) {
    final newId = DateTime.now().toString();
    dhikrs.add(CustomDhikr(id: newId, text: text));
    selectedDhikrId = newId; // പുതിയത് ആഡ് ചെയ്താൽ അത് സെലക്ട് ആകും
    notifyListeners();
  }

  void editDhikr(String id, String newText) {
    var d = dhikrs.firstWhere((d) => d.id == id);
    d.text = newText;
    notifyListeners();
  }

  void deleteDhikr(String id) {
    dhikrs.removeWhere((d) => d.id == id);
    if (selectedDhikrId == id) {
      selectedDhikrId = dhikrs.isNotEmpty ? dhikrs.first.id : null;
    }
    notifyListeners();
  }
}