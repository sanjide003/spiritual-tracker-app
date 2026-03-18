import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'prayer_controller.dart';
import '../../core/localization/app_localizations.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<PrayerController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_prayer')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Missed Prayer Tracker',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Only keep track of missed prayers that still need to be made up. Use + and - to update each prayer quickly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: PrayerController.prayerNames.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final prayer = PrayerController.prayerNames[index];
                  final count = ctrl.countFor(prayer);
                  return _PrayerCounterCard(
                    prayer: prayer,
                    count: count,
                    onIncrement: () => ctrl.incrementMissedPrayer(prayer),
                    onDecrement: () => ctrl.decrementMissedPrayer(prayer),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pending Qadha',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ctrl.getTotalPendingQadha()}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerCounterCard extends StatelessWidget {
  const _PrayerCounterCard({
    required this.prayer,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String prayer;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prayer,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
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
                child: OutlinedButton.icon(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove),
                  label: const Text('Minus'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add),
                  label: const Text('Plus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
