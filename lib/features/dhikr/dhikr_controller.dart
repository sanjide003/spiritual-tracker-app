// 📂 File: lib/features/dhikr/dhikr_controller.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/app_models.dart';
import '../../services/database_service.dart';

class DhikrController extends ChangeNotifier {
  DhikrController() {
    if (dhikrs.isNotEmpty) {
      selectedDhikrId = dhikrs.first.id;
    }
    _ensureTodayHistoryEntry();
  }

  static const String _dailyDhikrHistoryKey = 'daily_dhikr_history';

  final Box<CustomDhikr> _dhikrBox = Hive.box<CustomDhikr>(DatabaseService.dhikrsBoxName);
  final Box<Map> _analyticsBox = Hive.box<Map>(DatabaseService.analyticsBoxName);

  String? selectedDhikrId;

  List<CustomDhikr> get dhikrs => _dhikrBox.values.toList();

  CustomDhikr? get selectedDhikr {
    if (selectedDhikrId == null || dhikrs.isEmpty) return null;
    try {
      return dhikrs.firstWhere((d) => d.id == selectedDhikrId);
    } catch (e) {
      return null;
    }
  }

  void selectDhikr(String id) {
    selectedDhikrId = id;
    notifyListeners();
  }

  Future<void> increment() async {
    if (selectedDhikr == null) return;
    selectedDhikr!.count++;
    await selectedDhikr!.save();
    await _incrementTodayHistory();
    notifyListeners();
  }

  void addDhikr(String text) {
    final newId = DateTime.now().toIso8601String();
    final newDhikr = CustomDhikr(id: newId, text: text, count: 0);
    _dhikrBox.put(newId, newDhikr);
    selectedDhikrId = newId;
    _ensureTodayHistoryEntry();
    notifyListeners();
  }

  void editDhikr(String id, String newText) {
    final dhikr = _dhikrBox.get(id);
    if (dhikr == null) return;
    dhikr.text = newText;
    dhikr.save();
    notifyListeners();
  }

  void deleteDhikr(String id) {
    _dhikrBox.delete(id);
    if (selectedDhikrId == id) {
      selectedDhikrId = dhikrs.isNotEmpty ? dhikrs.first.id : null;
    }
    notifyListeners();
  }

  int getTotalDhikrCount() {
    return dhikrs.fold(0, (sum, item) => sum + item.count);
  }

  int getTodayDhikrCount() {
    final history = _dailyHistory;
    return (history[_todayKey()] as int?) ?? 0;
  }

  List<int> getLast7DaysCounts() {
    final history = _dailyHistory;
    return List<int>.generate(7, (index) {
      final day = DateTime.now().subtract(Duration(days: 6 - index));
      return (history[_dayKey(day)] as int?) ?? 0;
    });
  }

  List<String> getLast7DayLabels() {
    return List<String>.generate(7, (index) {
      final day = DateTime.now().subtract(Duration(days: 6 - index));
      return _weekdayLabel(day.weekday);
    });
  }

  Map<String, dynamic> get _dailyHistory {
    return Map<String, dynamic>.from(
      _analyticsBox.get(_dailyDhikrHistoryKey) ?? <String, dynamic>{},
    );
  }

  Future<void> _incrementTodayHistory() async {
    final history = _dailyHistory;
    final key = _todayKey();
    history[key] = ((history[key] as int?) ?? 0) + 1;
    await _analyticsBox.put(_dailyDhikrHistoryKey, history);
  }

  void _ensureTodayHistoryEntry() {
    final history = _dailyHistory;
    final key = _todayKey();
    if (history.containsKey(key)) return;
    history[key] = 0;
    _analyticsBox.put(_dailyDhikrHistoryKey, history);
  }

  String _todayKey() => _dayKey(DateTime.now());

  String _dayKey(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }
}
