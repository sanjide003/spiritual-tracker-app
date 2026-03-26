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
    final obligatoryItems = items.where((item) => !item.isSunnah).toList();
    final otherItems = items.where((item) => item.isSunnah).toList();

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
            if (ctrl.isTrackerIntroVisible) ...[
              const SizedBox(height: 10),
              _TrackerIntroCard(
                title: lang.translate('prayer_tracker_title'),
                subtitle: lang.translate('prayer_tracker_subtitle'),
                onClose: ctrl.dismissTrackerIntro,
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  _PrayerGrid(
                    items: obligatoryItems,
                    labelResolver: (item) => lang.translate('prayer_${item.name.toLowerCase()}'),
                    onIncrement: (item) => ctrl.incrementMissedPrayer(item.name),
                    onDecrement: (item) => ctrl.decrementMissedPrayer(item.name),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang.translate('prayer_others_title'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (otherItems.isEmpty)
                    _EmptyOthersHint(message: lang.translate('prayer_others_empty'))
                  else
                    _PrayerGrid(
                      items: otherItems,
                      labelResolver: (item) => item.name,
                      onIncrement: (item) => ctrl.incrementSunnahPrayer(item.id),
                      onDecrement: (item) => ctrl.decrementSunnahPrayer(item.id),
                      onEdit: (item) => _showEditSunnahDialog(context, item),
                      onDelete: (item) => ctrl.deleteSunnahPrayer(item.id),
                    ),
                ],
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

  Future<void> _showEditSunnahDialog(BuildContext context, PrayerCounterItem item) async {
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);
    final ctrl = Provider.of<PrayerController>(context, listen: false);
    final nameController = TextEditingController(text: item.name);
    final rakatsController = TextEditingController(text: '${item.rakats}');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(lang.translate('prayer_edit_sunnah_title')),
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
                await ctrl.updateSunnahPrayer(id: item.id, name: name, rakats: rakats);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: Text(lang.translate('common_update')),
            ),
          ],
        );
      },
    );
  }
}

class _TrackerIntroCard extends StatelessWidget {
  const _TrackerIntroCard({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onClose(),
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _PrayerGrid extends StatelessWidget {
  const _PrayerGrid({
    required this.items,
    required this.labelResolver,
    required this.onIncrement,
    required this.onDecrement,
    this.onEdit,
    this.onDelete,
  });

  final List<PrayerCounterItem> items;
  final String Function(PrayerCounterItem item) labelResolver;
  final Future<void> Function(PrayerCounterItem item) onIncrement;
  final Future<void> Function(PrayerCounterItem item) onDecrement;
  final Future<void> Function(PrayerCounterItem item)? onEdit;
  final Future<void> Function(PrayerCounterItem item)? onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _PrayerCounterCard(
          prayer: labelResolver(item),
          rakats: item.rakats,
          count: item.count,
          onIncrement: () {
            onIncrement(item);
          },
          onDecrement: () {
            onDecrement(item);
          },
          onEdit: onEdit == null
              ? null
              : () {
                  onEdit!(item);
                },
          onDelete: onDelete == null
              ? null
              : () {
                  onDelete!(item);
                },
        );
      },
    );
  }
}

class _EmptyOthersHint extends StatelessWidget {
  const _EmptyOthersHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
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
    this.onEdit,
    this.onDelete,
  });

  final String prayer;
  final int rakats;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  prayer,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(lang.translate('common_update')),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(lang.translate('common_delete')),
                      ),
                  ],
                ),
            ],
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
