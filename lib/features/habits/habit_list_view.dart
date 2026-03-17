// 📂 File: lib/features/habits/habit_list_view.dart
// മൂന്നാമത്തെ ടാബ് (ഹാബിറ്റ്സ്)

import 'package:flutter/material.dart';

class HabitListView extends StatelessWidget {
  const HabitListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Habits'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Daily, Weekly, Monthly Habits go here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}