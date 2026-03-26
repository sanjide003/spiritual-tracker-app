import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/database_service.dart';

class PrayerCounterItem {
  const PrayerCounterItem({
    required this.id,
    required this.name,
    required this.rakats,
    required this.count,
    required this.isSunnah,
  });

  final String id;
  final String name;
  final int rakats;
  final int count;
  final bool isSunnah;
}

class PrayerController extends ChangeNotifier {
  static const List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const Map<String, int> obligatoryPrayerRakats = {
    'Fajr': 2,
    'Dhuhr': 4,
    'Asr': 4,
    'Maghrib': 3,
    'Isha': 4,
  };

  static const String _missedPrayerKey = 'missed_prayer_counts';
  static const String _dailyPendingQadhaKey = 'daily_pending_qadha_history';
  static const String _sunnahPrayersKey = 'sunnah_prayer_items';

  final Box<Map> _defaultBox = Hive.box<Map>(DatabaseService.defaultPrayersBoxName);
  final Box<Map> _analyticsBox = Hive.box<Map>(DatabaseService.analyticsBoxName);

  Map<String, int> missedPrayerCounts = {for (final prayer in prayerNames) prayer: 0};
  List<Map<String, dynamic>> sunnahPrayerItems = const [];

  PrayerController() {
    _loadMissedCounts();
    _loadSunnahPrayers();
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

  void _loadSunnahPrayers() {
    final savedItems = _defaultBox.get(_sunnahPrayersKey);
    if (savedItems == null) return;

    final values = (savedItems['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    sunnahPrayerItems = values;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _defaultBox.put(_missedPrayerKey, missedPrayerCounts);
    await _defaultBox.put(_sunnahPrayersKey, {'items': sunnahPrayerItems});
    await _recordTodaySnapshot();
    notifyListeners();
  }

  int countFor(String prayer) => missedPrayerCounts[prayer] ?? 0;

  List<PrayerCounterItem> get counterItems {
    final obligatory = prayerNames.map(
      (name) => PrayerCounterItem(
        id: name,
        name: name,
        rakats: obligatoryPrayerRakats[name] ?? 0,
        count: missedPrayerCounts[name] ?? 0,
        isSunnah: false,
      ),
    );

    final sunnah = sunnahPrayerItems.map(
      (item) => PrayerCounterItem(
        id: item['id'] as String? ?? '',
        name: item['name'] as String? ?? '',
        rakats: (item['rakats'] as num?)?.toInt() ?? 0,
        count: (item['count'] as num?)?.toInt() ?? 0,
        isSunnah: true,
      ),
    );

    return [...obligatory, ...sunnah];
  }

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

  Future<void> incrementSunnahPrayer(String id) async {
    final index = sunnahPrayerItems.indexWhere((item) => item['id'] == id);
    if (index == -1) return;
    final current = (sunnahPrayerItems[index]['count'] as num?)?.toInt() ?? 0;
    sunnahPrayerItems[index]['count'] = current + 1;
    await _persist();
  }

  Future<void> decrementSunnahPrayer(String id) async {
    final index = sunnahPrayerItems.indexWhere((item) => item['id'] == id);
    if (index == -1) return;
    final current = (sunnahPrayerItems[index]['count'] as num?)?.toInt() ?? 0;
    if (current == 0) return;
    sunnahPrayerItems[index]['count'] = current - 1;
    await _persist();
  }

  Future<void> addSunnahPrayer({
    required String name,
    required int rakats,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || rakats <= 0) return;

    final id = 'sunnah_${DateTime.now().microsecondsSinceEpoch}';
    final updated = List<Map<String, dynamic>>.from(sunnahPrayerItems)
      ..add({'id': id, 'name': trimmedName, 'rakats': rakats, 'count': 0});
    sunnahPrayerItems = updated;
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
