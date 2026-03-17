// 📂 File: lib/features/habits/habit_controller.dart

import 'package:flutter/material.dart';

class HabitItem {
  String title;
  bool isCompleted;
  String frequency; // 'Daily', 'Weekly', 'Monthly'

  HabitItem({required this.title, this.isCompleted = false, this.frequency = 'Daily'});
}

class HabitController extends ChangeNotifier {
  final List<HabitItem> habits = [
    HabitItem(title: 'Read Quran'),
    HabitItem(title: 'Give Charity', frequency: 'Weekly'),
  ];

  void toggleHabit(int index) {
    habits[index].isCompleted = !habits[index].isCompleted;
    notifyListeners();
  }

  void addHabit(String title, String frequency) {
    habits.add(HabitItem(title: title, frequency: frequency));
    notifyListeners();
  }

  void deleteHabit(int index) {
    habits.removeAt(index);
    notifyListeners();
  }
}