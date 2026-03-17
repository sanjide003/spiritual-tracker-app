// 📂 File: lib/features/dhikr/dhikr_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dhikr_controller.dart';
import '../../core/localization/app_localizations.dart';

class DhikrListView extends StatelessWidget {
  const DhikrListView({super.key});

  @override
  Widget build(BuildContext context) {
    final dhikrCtrl = Provider.of<DhikrController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_dhikr')),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: dhikrCtrl.dhikrs.length,
        itemBuilder: (context, index) {
          final dhikr = dhikrCtrl.dhikrs[index];
          final progress = dhikr.count / dhikr.target;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => dhikrCtrl.incrementCount(index),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            dhikr.title,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // റീസെറ്റ് ബട്ടൺ & ഡിലീറ്റ് ബട്ടൺ
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => dhikrCtrl.resetCount(index),
                              tooltip: 'Reset',
                            ),
                            if (index > 2) // ഡിഫോൾട്ട് ദിക്റുകൾ അല്ലാത്തവ മാത്രം ഡിലീറ്റ് ചെയ്യാം
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => dhikrCtrl.deleteDhikr(index),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // കൗണ്ടർ കാണിക്കുന്ന ഭാഗം
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${dhikr.count}',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${dhikr.target}',
                          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // പ്രോഗ്രസ് ബാർ
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      color: progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // പുതിയ ദിക്റ് ആഡ് ചെയ്യാനുള്ള ബട്ടൺ
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDhikrDialog(context, dhikrCtrl),
        child: const Icon(Icons.add),
      ),
    );
  }

  // പുതിയ ദിക്റ് ആഡ് ചെയ്യാനുള്ള പോപ്പ്-അപ്പ് ബോക്സ്
  void _showAddDhikrDialog(BuildContext context, DhikrController ctrl) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Dhikr'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Dhikr Name'),
              ),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target Count'),
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
                if (titleController.text.isNotEmpty && targetController.text.isNotEmpty) {
                  int target = int.tryParse(targetController.text) ?? 33;
                  ctrl.addCustomDhikr(titleController.text, target);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}