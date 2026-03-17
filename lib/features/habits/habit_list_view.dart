// 📂 File: lib/features/habits/habit_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_controller.dart';
import '../../core/localization/app_localizations.dart';

class HabitListView extends StatelessWidget {
  const HabitListView({super.key});

  @override
  Widget build(BuildContext context) {
    final habitCtrl = Provider.of<HabitController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_habits')),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: habitCtrl.habits.length,
        itemBuilder: (context, index) {
          final habit = habitCtrl.habits[index];
          return ListTile(
            leading: Checkbox(
              value: habit.isCompleted,
              onChanged: (val) => habitCtrl.toggleHabit(index),
            ),
            title: Text(
              habit.title,
              style: TextStyle(
                decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(habit.frequency),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => habitCtrl.deleteHabit(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context, habitCtrl),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, HabitController ctrl) {
    final titleController = TextEditingController();
    String selectedFrequency = 'Daily';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Habit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Habit Name'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedFrequency,
                    isExpanded: true,
                    items: ['Daily', 'Weekly', 'Monthly'].map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        selectedFrequency = newVal!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      ctrl.addHabit(titleController.text, selectedFrequency);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}