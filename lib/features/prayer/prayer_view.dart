// 📂 File: lib/features/prayer/prayer_view.dart

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
      body: Column(
        children: [
          // തീയതി മാറ്റാനുള്ള സംവിധാനം (< Date >)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => ctrl.changeDate(-1),
                ),
                Text(
                  ctrl.formattedDate,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => ctrl.changeDate(1),
                ),
              ],
            ),
          ),
          const Divider(),
          
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Fardh (Obligatory) Prayers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                // 5 വഖ്ത് നിസ്കാരങ്ങൾ
                ...ctrl.defaultPrayers.keys.map((prayer) {
                  return ListTile(
                    title: Text(prayer, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: DropdownButton<String>(
                      value: ctrl.defaultPrayers[prayer] == 'None' ? null : ctrl.defaultPrayers[prayer],
                      hint: const Text('Status'),
                      items: ['Ada', 'Qadha', 'Missed'].map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) ctrl.updateDefaultPrayer(prayer, val);
                      },
                    ),
                  );
                }),
                
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Sunnah (Custom) Prayers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                
                // സുന്നത്ത് നിസ്കാരങ്ങളുടെ ലിസ്റ്റ് (3-ഡോട്ട് മെനുവോടെ)
                if (ctrl.sunnahPrayers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No custom prayers added.', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ...ctrl.sunnahPrayers.map((sunnah) {
                  return CheckboxListTile(
                    value: sunnah.isCompleted,
                    onChanged: (val) => ctrl.toggleSunnahStatus(sunnah.id),
                    title: Text(sunnah.name),
                    subtitle: Text('${sunnah.rakah} Rakahs'),
                    secondary: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                           _showAddEditSunnahDialog(context, ctrl, isEdit: true, existingId: sunnah.id, name: sunnah.name, rakah: sunnah.rakah);
                        } else if (value == 'delete') {
                           ctrl.deleteSunnahPrayer(sunnah.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSunnahDialog(context, ctrl),
        icon: const Icon(Icons.add),
        label: const Text('Add Sunnah'),
      ),
    );
  }

  // സുന്നത്ത് ആഡ്/എഡിറ്റ് ചെയ്യാനുള്ള പോപ്പ്-അപ്പ്
  void _showAddEditSunnahDialog(BuildContext context, PrayerController ctrl, {bool isEdit = false, String? existingId, String? name, int? rakah}) {
    final nameCtrl = TextEditingController(text: name ?? '');
    final rakahCtrl = TextEditingController(text: rakah?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Sunnah Prayer' : 'Add Sunnah Prayer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Prayer Name')),
            TextField(controller: rakahCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Number of Rakahs')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && rakahCtrl.text.isNotEmpty) {
                int r = int.tryParse(rakahCtrl.text) ?? 2;
                if (isEdit) {
                  ctrl.editSunnahPrayer(existingId!, nameCtrl.text, r);
                } else {
                  ctrl.addSunnahPrayer(nameCtrl.text, r);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }
}