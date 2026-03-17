// 📂 File: lib/features/dhikr/dhikr_list_view.dart
// രണ്ടാമത്തെ ടാബ് (ദിക്റ്)

import 'package:flutter/material.dart';

class DhikrListView extends StatelessWidget {
  const DhikrListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhikr Counter'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Dhikr List and Counter goes here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}