// 📂 File: lib/features/dhikr/dhikr_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dhikr_controller.dart';
import '../../core/localization/app_localizations.dart';

class DhikrListView extends StatelessWidget {
  const DhikrListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<DhikrController>(context);
    final lang = Provider.of<AppLanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('tab_dhikr')),
        centerTitle: true,
        actions: [
          // സെലക്ട് ചെയ്ത ദിക്ർ എഡിറ്റ്/ഡിലീറ്റ് ചെയ്യാനുള്ള 3 ഡോട്ട്
          if (ctrl.selectedDhikr != null)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  _showAddEditDialog(context, ctrl, isEdit: true, id: ctrl.selectedDhikr!.id, text: ctrl.selectedDhikr!.text);
                } else if (val == 'delete') {
                  ctrl.deleteDhikr(ctrl.selectedDhikr!.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            )
        ],
      ),
      body: Column(
        children: [
          // ഡ്രോപ്പ്-ഡൗൺ സെലക്ഷൻ
          if (ctrl.dhikrs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Select Dhikr'),
                value: ctrl.selectedDhikrId,
                items: ctrl.dhikrs.map((d) {
                  return DropdownMenuItem(value: d.id, child: Text(d.text));
                }).toList(),
                onChanged: (val) {
                  if (val != null) ctrl.selectDhikr(val);
                },
              ),
            ),
          
          Expanded(
            child: ctrl.dhikrs.isEmpty
                ? const Center(child: Text('No Dhikr added yet. Tap + to add.'))
                : GestureDetector(
                    onTap: ctrl.increment, // സ്ക്രീനിൽ എവിടെ തൊട്ടാലും കൗണ്ട് കൂടും
                    child: Container(
                      color: Colors.transparent, // മുഴുവൻ സ്ക്രീനും ക്ലിക്കബിൾ ആക്കാൻ
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ctrl.selectedDhikr?.text ?? '',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: Text(
                                '${ctrl.selectedDhikr?.count ?? 0}',
                                style: TextStyle(fontSize: 64, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Tap anywhere to count', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, ctrl),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, DhikrController ctrl, {bool isEdit = false, String? id, String? text}) {
    final textCtrl = TextEditingController(text: text ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Dhikr' : 'Add New Dhikr'),
        content: TextField(controller: textCtrl, decoration: const InputDecoration(hintText: 'Enter Dhikr text')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (textCtrl.text.isNotEmpty) {
                if (isEdit) ctrl.editDhikr(id!, textCtrl.text);
                else ctrl.addDhikr(textCtrl.text);
                Navigator.pop(context);
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          )
        ],
      ),
    );
  }
}