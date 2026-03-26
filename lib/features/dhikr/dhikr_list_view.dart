// 📂 File: lib/features/dhikr/dhikr_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import 'dhikr_controller.dart';

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
                PopupMenuItem(value: 'edit', child: Text(lang.translate('dhikr_edit'))),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(lang.translate('common_delete'), style: const TextStyle(color: Colors.red)),
                ),
              ],
            )
        ],
      ),
      body: Column(
        children: [
          if (ctrl.dhikrs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: lang.translate('dhikr_select'),
                ),
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
                ? Center(child: Text(lang.translate('dhikr_empty')))
                : GestureDetector(
                    onTap: ctrl.increment,
                    child: Container(
                      color: Colors.transparent,
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
                                style: TextStyle(
                                  fontSize: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              lang.translate('dhikr_tap'),
                              style: const TextStyle(color: Colors.grey),
                            ),
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
    final lang = Provider.of<AppLanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate(isEdit ? 'dhikr_edit' : 'dhikr_add_new')),
        content: TextField(
          controller: textCtrl,
          decoration: InputDecoration(hintText: lang.translate('dhikr_hint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(lang.translate('common_cancel'))),
          ElevatedButton(
            onPressed: () {
              if (textCtrl.text.isNotEmpty) {
                if (isEdit) {
                  ctrl.editDhikr(id!, textCtrl.text);
                } else {
                  ctrl.addDhikr(textCtrl.text);
                }
                Navigator.pop(context);
              }
            },
            child: Text(lang.translate(isEdit ? 'common_save' : 'common_add')),
          )
        ],
      ),
    );
  }
}
