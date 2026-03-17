// 📂 File: lib/features/prayer/prayer_view.dart
// ഒന്നാമത്തെ ടാബ് (നിസ്കാരം & ഖളാഅ്)

import 'package:flutter/material.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer & Qadha'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Prayer Tracker goes here\n(Ada & Qadha)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}