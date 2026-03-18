import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PrayerController extends ChangeNotifier {
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  final Box<Map> _defaultBox = Hive.box<Map>('defaultPrayersBox');
  static const String _missedPrayerKey = 'missed_prayer_counts';

  Map<String, int> missedPrayerCounts = {
    for (final prayer in prayerNames) prayer: 0,
  };

  PrayerController() {
    _loadMissedCounts();
  }

  void _loadMissedCounts() {
    final savedCounts = _defaultBox.get(_missedPrayerKey);
    if (savedCounts != null) {
      missedPrayerCounts = {
        for (final prayer in prayerNames)
          prayer: (savedCounts[prayer] as int?) ?? 0,
      };
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    await _defaultBox.put(_missedPrayerKey, missedPrayerCounts);
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
}
