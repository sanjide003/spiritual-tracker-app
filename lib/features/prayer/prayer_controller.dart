import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/database_service.dart';

class PrayerController extends ChangeNotifier {
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];
  static const String _missedPrayerKey = 'missed_prayer_counts';
  static const String _dailyPendingQadhaKey = 'daily_pending_qadha_history';

  final Box<Map> _defaultBox = Hive.box<Map>(DatabaseService.defaultPrayersBoxName);
  final Box<Map> _analyticsBox = Hive.box<Map>(DatabaseService.analyticsBoxName);

  Map<String, int> missedPrayerCounts = {
    for (final prayer in prayerNames) prayer: 0,
  };

  PrayerController() {
    _loadMissedCounts();
    _recordTodaySnapshot();
  }

  void _loadMissedCounts() {
    final savedCounts = _defaultBox.get(_missedPrayerKey);
    if (savedCounts != null) {
      missedPrayerCounts = {
        for (final prayer in prayerNames) prayer: (savedCounts[prayer] as int?) ?? 0,
      };
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await _defaultBox.put(_missedPrayerKey, missedPrayerCounts);
    await _recordTodaySnapshot();
    notifyListeners();
  }

  int countFor(String prayer) => missedPrayerCounts[prayer] ?? 0;

  Future<void> incrementMissedPrayer(String prayer) async {
    missedPrayerCounts[prayer] = countFor(prayer) + 1;
    await _persist();
  }

  Future<void> decrementMissedPrayer(String prayer) async {
    final current = countFor(prayer);
    if (current == 0) return;
    missedPrayerCounts[prayer] = current - 1;
    await _persist();
  }

  int getTotalPendingQadha() {
    return missedPrayerCounts.values.fold(0, (sum, count) => sum + count);
  }

  List<int> getLast7DaysPendingQadha() {
    final history = Map<String, dynamic>.from(
      _analyticsBox.get(_dailyPendingQadhaKey) ?? <String, dynamic>{},
    );
    return List<int>.generate(7, (index) {
      final day = DateTime.now().subtract(Duration(days: 6 - index));
      return (history[_dayKey(day)] as int?) ?? 0;
    });
  }

  Future<void> _recordTodaySnapshot() async {
    final history = Map<String, dynamic>.from(
      _analyticsBox.get(_dailyPendingQadhaKey) ?? <String, dynamic>{},
    );
    history[_dayKey(DateTime.now())] = getTotalPendingQadha();
    await _analyticsBox.put(_dailyPendingQadhaKey, history);
  }

  String _dayKey(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
