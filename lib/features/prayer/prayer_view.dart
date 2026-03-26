import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import 'prayer_controller.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<PrayerController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);
    final items = ctrl.counterItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_prayer')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSunnahDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.translate('prayer_tracker_title'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              lang.translate('prayer_tracker_subtitle'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final prayerLabel = item.isSunnah
                      ? item.name
                      : lang.translate('prayer_${item.name.toLowerCase()}');
                  return _PrayerCounterCard(
                    prayer: prayerLabel,
                    rakats: item.rakats,
                    count: item.count,
                    onIncrement: item.isSunnah
                        ? () => ctrl.incrementSunnahPrayer(item.id)
                        : () => ctrl.incrementMissedPrayer(item.name),
                    onDecrement: item.isSunnah
                        ? () => ctrl.decrementSunnahPrayer(item.id)
                        : () => ctrl.decrementMissedPrayer(item.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddSunnahDialog(BuildContext context) async {
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);
    final ctrl = Provider.of<PrayerController>(context, listen: false);
    final nameController = TextEditingController();
    final rakatsController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(lang.translate('prayer_add_sunnah_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: lang.translate('prayer_sunnah_name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rakatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: lang.translate('prayer_rakats_input_label'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(lang.translate('common_cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final rakats = int.tryParse(rakatsController.text.trim()) ?? 0;
                if (name.isEmpty || rakats <= 0) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(lang.translate('prayer_sunnah_validation_error'))),
                  );
                  return;
                }
                await ctrl.addSunnahPrayer(name: name, rakats: rakats);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: Text(lang.translate('common_add')),
            ),
          ],
        );
      },
    );
  }
}

class _PrayerCounterCard extends StatelessWidget {
  const _PrayerCounterCard({
    required this.prayer,
    required this.rakats,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String prayer;
  final int rakats;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prayer,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            lang.translateWithArgs('prayer_rakats_count', {'count': '$rakats'}),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Center(
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: onDecrement,
                  child: const Icon(Icons.remove),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onIncrement,
                  child: const Icon(Icons.add),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
