// 📂 File: lib/features/dhikr/dhikr_controller.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/app_models.dart';

class DhikrController extends ChangeNotifier {
  final Box<CustomDhikr> _dhikrBox = Hive.box<CustomDhikr>('dhikrsBox');
  String? selectedDhikrId;

  List<CustomDhikr> get dhikrs => _dhikrBox.values.toList();

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
      selectedDhikr!.save(); // ഡാറ്റാബേസിലേക്ക് സേവ് ആകുന്നു
      notifyListeners();
    }
  }

  void addDhikr(String text) {
    final newId = DateTime.now().toString();
    final newDhikr = CustomDhikr(id: newId, text: text, count: 0);
    _dhikrBox.put(newId, newDhikr);
    selectedDhikrId = newId;
    notifyListeners();
  }

  void editDhikr(String id, String newText) {
    var d = _dhikrBox.get(id);
    if (d != null) {
      d.text = newText;
      d.save();
      notifyListeners();
    }
  }

  void deleteDhikr(String id) {
    _dhikrBox.delete(id);
    if (selectedDhikrId == id) {
      selectedDhikrId = dhikrs.isNotEmpty ? dhikrs.first.id : null;
    }
    notifyListeners();
  }

  // ഡാഷ്‌ബോർഡിന് വേണ്ടി ഇന്നത്തെ ആകെ ദിക്റുകൾ
  int getTotalDhikrCount() {
    return dhikrs.fold(0, (sum, item) => sum + item.count);
  }
}