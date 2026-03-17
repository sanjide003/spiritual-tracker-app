// 📂 File: lib/features/prayer/prayer_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prayer_controller.dart';
import '../../core/localization/app_localizations.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerCtrl = Provider.of<PrayerController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);
    final theme = Theme.of(context);

    // ആകെ ബാക്കിയുള്ള ഖളാഅ് എണ്ണം കണക്കാക്കുന്നു
    int totalQadha = prayerCtrl.qadhaCount.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_prayer')),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // മുകളിലുള്ള ഖളാഅ് സബ്-ഹെഡ്ഡർ ബോക്സ്
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Qadha',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap on a prayer to reduce count',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$totalQadha',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),

          // 5 വഖ്ത് നിസ്കാരങ്ങളുടെ ലിസ്റ്റ്
          Expanded(
            child: ListView.builder(
              itemCount: prayerCtrl.todayPrayers.length,
              itemBuilder: (context, index) {
                String prayerName = prayerCtrl.todayPrayers.keys.elementAt(index);
                String currentStatus = prayerCtrl.todayPrayers[prayerName]!;
                int qadhaCount = prayerCtrl.qadhaCount[prayerName]!;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // നിസ്കാരത്തിന്റെ പേരും ഖളാഅ് എണ്ണവും
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              prayerName,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            // ഖളാഅ് വീട്ടാനുള്ള ബട്ടൺ
                            if (qadhaCount > 0)
                              ActionChip(
                                backgroundColor: theme.colorScheme.errorContainer,
                                label: Text('Qadha: $qadhaCount (Tap to reduce)'),
                                labelStyle: TextStyle(color: theme.colorScheme.onErrorContainer),
                                onPressed: () {
                                  prayerCtrl.decrementQadha(prayerName);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // അദാഅ്, ഖളാഅ്, മിസ്സ്ഡ് ബട്ടണുകൾ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatusButton(
                              context, 
                              title: 'Ada', 
                              isSelected: currentStatus == 'Ada', 
                              activeColor: Colors.green,
                              onTap: () => prayerCtrl.updateTodayPrayer(prayerName, 'Ada'),
                            ),
                            _buildStatusButton(
                              context, 
                              title: 'Qadha', 
                              isSelected: currentStatus == 'Qadha', 
                              activeColor: Colors.orange,
                              onTap: () => prayerCtrl.updateTodayPrayer(prayerName, 'Qadha'),
                            ),
                            _buildStatusButton(
                              context, 
                              title: 'Missed', 
                              isSelected: currentStatus == 'Missed', 
                              activeColor: Colors.red,
                              onTap: () => prayerCtrl.updateTodayPrayer(prayerName, 'Missed'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ചെറിയ സ്റ്റാറ്റസ് ബട്ടൺ ഡിസൈൻ
  Widget _buildStatusButton(BuildContext context, {required String title, required bool isSelected, required Color activeColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? activeColor : Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? activeColor : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}